# Feature: Home

Dashboard principal con totales, prioridades y prospectos recientes.

## Archivos clave

| Archivo | Qué hace |
|---|---|
| `data/datasources/remote/home_remote_datasource.dart` | Consulta dashboard |
| `data/models/home_model.dart` | Parseo multi-sección |
| `data/models/prioridad_home_model.dart` | Leads de alta prioridad |
| `data/models/prospecto_home_model.dart` | Prospectos recientes |
| `domain/entities/home.dart` | Entidad pura |
| `domain/entities/prioridad_home.dart` | Entidad pura |
| `presentation/bloc/home/home_bloc.dart` | Estado del dashboard |
| `presentation/bloc/notifications/notifications_bloc.dart` | Estado de las notificaciones |
| `presentation/pages/home_page.dart` | Crea el BlocProvider |
| `presentation/widgets/` | Cards, listas, badges |

---

## Parseo multi-sección — patrón de HomeModel

La respuesta del SP tiene 3 secciones separadas por `AppConstants.sepListas` (`¯`):

```
sección0 ¯ sección1 ¯ sección2
totales  ¯ prioridades ¯ prospectos
```

```dart
static HomeModel parse(String rawResponse) {
  final partes = rawResponse.split(AppConstants.sepListas);
  final totalesRaw     = partes[0];                          // siempre existe
  final prioridadesRaw = partes.length > 1 ? partes[1] : '';
  final prospectosRaw  = partes.length > 2 ? partes[2] : '';
  // ...
}
```

**Siempre verificar `partes.length > N` antes de acceder** — el SP puede omitir secciones vacías.

---

## Parseo de totales

`HomeModel.parse` usa `ParseUtils.toInt(c, i)` sobre `totalesRaw.split(AppConstants.sepCampos)`.
Índices reales (el orden documentado antes acá no coincidía con el código — corregido
2026-08-14):

```
c(0) → totLeadsNuevos
c(1) → totLeadsDesarrollo
c(2) → totPropuestas
c(3) → totSeguimientos            (= totLeadsNuevos + totLeadsDesarrollo + totPropuestas)
c(4) → totCobranza
c(5) → totConversaciones
c(6) → totNotificaciones
c(7) → totSolicitudesSinValidar
c(8) → totSeguimientosActivos
```

---

## Badges del drawer/dashboard — qué cuenta cada total (2026-08-14)

Pedido de negocio: los badges no debían contar "todo lo activo", sino solo lo que requiere
acción del asesor. `CRM.CSV_HOME_LST_APP` (tarea `L`) filtra cada total en el propio SP:

- **`totConversaciones`** — antes contaba cualquier conversación activa sin importar quién
  mandó el último mensaje (con 3 negociaciones donde el asesor ya había respondido, igual
  mostraba "3"). Ahora el `WHERE` de esa sección suma `AND CD.DIRECCION = 'CLI'` — solo cuenta
  si el **último** mensaje (la fila que ya resolvía `MAX(ID_CONVERSACION_DET)`) lo mandó el
  cliente. `DIRECCION` tiene 3 valores posibles (ver `CRM.CSV_WHATSAPP_CHAT_CUD_SP_V03.sql`):
  `'CLI'` cliente, `'ASE'` asesor, `'AIA'` asistente IA.
- **`totCobranza`** — antes contaba todo `EVT.T_TECMSOLINSCRIPCION01` con
  `IB_TIPO_CRM = 1 AND IB_VALIDADO != 0`, sin filtrar por estado. Ahora suma
  `AND CI.ID_ESTADO_GES = 0` — solo "Pend. de Documento" (mismo código que usa la tarjeta
  "Pend. documento" de `CobranzaSummaryCards`, ver `cobranza/CLAUDE.md` → sección "Estado").
- **`totSolicitudesSinValidar`** (nuevo, índice `c(7)`) — mismo patrón que `totCobranza` pero
  con `CI.IB_VALIDADO = 0` (sin filtro de `ID_ESTADO_GES`) — cuenta solicitudes de
  `EVT.T_TECMSOLINSCRIPCION01` (`IB_TIPO_CRM = 1`) que todavía no fueron validadas. Alimenta el
  badge del ítem "Solicitudes" del drawer, que antes no tenía ningún contador.
- **`totNotificaciones`** ya filtraba `NT.IB_LEIDO = 0` desde antes — no se tocó, solo se
  confirmó que ya estaba bien (se muestra en la campanita del AppBar de Home, no en el drawer).

En Flutter, el badge de "Conversaciones" del drawer tiene **dos escritores** — no alcanza con
arreglar el SP solo: `HomePage` (`context.updateBadge(conversaciones: state.totConversaciones)`,
al cargar/refrescar Home) y `ChatListPage` (`context.updateBadge(conversaciones:
state.contadores.sinResponder)`, cada vez que `ChatListBloc` — que es global, ver
`chat/CLAUDE.md` — emite `ChatListSuccess`). Antes `ChatListPage` mandaba
`state.conversaciones.length`, el tamaño de la lista **ya filtrada** por el chip activo del Chat
List (con el chip "Sin responder" daba el número correcto por casualidad, con cualquier otro
chip mandaba un número distinto al que el usuario veía en el drawer) — se cambió a
`state.contadores.sinResponder`, que `ChatListBloc._calcularContadores` siempre calcula sobre la
lista completa sin importar qué chip esté activo, mismo criterio `direccionMensaje == 'CLI'` que
ahora usa el SP.

---

## Badge "Seguimiento" del drawer — nuevo, "todos menos cerrados" (2026-08-14)

El ítem "Seguimiento" del drawer no tenía badge hasta ahora. Se agregó usando
`totSeguimientosActivos` (`c(8)` del SP, ver arriba) — cuenta **todas** las negociaciones del
asesor (o del equipo si es moderador) salvo las que estén cerradas o cuyo estado padre esté
cerrado: `LD.ID_ESTADO != '04' AND (LE.ID_ESTADO_PADRE != '04' OR LE.ID_ESTADO_PADRE IS NULL)`
— mismo patrón que ya usaba este mismo SP para resolver "el lead activo" de un número
(sección de prioridades). **Ojo, esto es distinto de `totSeguimientos`** (`c(3)`, sin tocar) —
ese sigue siendo la suma de solo 3 buckets (Nuevo+EnDesarrollo+Propuesta, estados `00`/`01`/`02`)
que alimenta las 3 tarjetas de `CardTotalesHome` (dashboard) — `totSeguimientos` nunca se usó
para el badge del drawer en la práctica (`HomePage` ahora manda `totSeguimientosActivos` a
`seguimientos:`, no `totSeguimientos`), así que redefinir su fuente no rompió ninguna UI.

**Real-time mientras Seguimiento está en pantalla** — `LeadListBloc` (per-página, no global, ver
`lead/CLAUDE.md`) calcula el mismo conteo del lado del cliente (`LeadListSuccess.activos`, sobre
`_allLeads` completo, mismo criterio `idEstado != '04' && idEstadoPadre != '04'`) y
`LeadListPage` lo empuja al badge en cada `LeadListSuccess` — incluye los casos en que
`LeadListBloc._onLeadUpdated` parchea un lead en memoria vía `LeadUpdateNotifier` (ej. se cierra
una negociación desde Conversaciones mientras Seguimiento sigue montado debajo). Fuera de esa
pantalla, el badge solo se actualiza cuando Home vuelve a cargar/refrescar (no hay bloc global
para Seguimiento, a diferencia de `ChatListBloc`).

## Badge "Solicitudes" del drawer — `cntSinValidar`, con una limitación real

Igual patrón: `SolicitudListPage` empuja `context.updateBadge(solicitudes:
state.cntSinValidar)` en cada `SolicitudListSuccess` (`cntSinValidar` ya existía en el bloc,
calculado sobre `_allSolicitudes` — ver `solicitudes/CLAUDE.md`). **Ojo — a diferencia de
Cobranza, no hay ningún botón en Flutter que ponga `IB_VALIDADO = 1`** (confirmado revisando el
feature completo — "Validar" en `SolicitudCard`/`BotonesDetalle` solo abre el wizard de edición,
`CSV_SOLICITUD_CUD_APP` task `'U'` nunca toca esa columna). O sea: el badge sí se actualiza en
tiempo real mientras el asesor está parado en la pantalla de Solicitudes (recarga/pull-to-
refresh), pero no hay ningún evento de "se validó una solicitud" que lo dispare al instante como
sí pasa con Cobranza (`CobranzaUpdateNotifier`) — si negocio confirma dónde/cómo se marca
`IB_VALIDADO` de verdad (otro sistema, un proceso de backend aparte), recién ahí tendría sentido
sumar un notifier equivalente acá.

---

## Parseo de lista (PrioridadHome / ProspectoHome)

```dart
// Lista separada por ¬, cada registro por ¦
static List<PrioridadHomeModel> parseList(String rawResponse) {
  return rawResponse
      .split(AppConstants.sepRegistros)  // ¬
      .where((r) => r.trim().isNotEmpty)
      .map((r) => PrioridadHomeModel.fromRawString(r))
      .toList();
}

factory PrioridadHomeModel.fromRawString(String raw) {
  final fields = raw.split(AppConstants.sepCampos); // ¦

  return PrioridadHomeModel(
    idNumero:        ParseUtils.toInt(fields, 0),
    idLead:          ParseUtils.toInt(fields, 1),
    nombre:          ParseUtils.str(fields, 2),
    telefono:        ParseUtils.str(fields, 3),
    idEstado:        ParseUtils.str(fields, 4),
    estado:          ParseUtils.str(fields, 5),
    idCanal:         ParseUtils.toInt(fields, 6),
    canal:           ParseUtils.str(fields, 7),
    fechaHora:       ParseUtils.str(fields, 8),
    prefijoTelefono: ParseUtils.str(fields, 9),
    // idChatCab — conversación más reciente del número (T_CONVERSACION_CAB),
    // se usa para navegar a ChatDetail con el mismo id que la lista de chats
    // y la lista de leads (ver goToDetalleChat).
    idChatCab:       ParseUtils.toInt(fields, 10),
    canal:     f(6),
    fechaHora: f(7),
  );
}
```

---

## Entidad Home — campos

```dart
home.totConversaciones  // int
home.totProspectos      // int
home.totPropuestas      // int
home.totCobranza        // int
home.totLeadsNuevos     // int
home.totLeadsDesarrollo // int
home.totNotificaciones  // int
home.prioridades        // List<PrioridadHome>
home.prospectos         // List<ProspectoHome>
```

---

## `ProspectoHome.nombreMostrar` — fallback a teléfono (2026-08-14)

Igual que `PrioridadHome.nombreMostrar`: si el contacto no tiene nombre registrado,
`nombreMostrar` cae a `telefonoCompleto` (`"$prefijoTelefono $telefono"`). `ProspectoTileHome`
usa `nombreMostrar` tanto en el avatar como en el texto principal, nunca `nombre` directo.

El SP `CRM.CSV_HOME_LST_APP` (tarea `L`, sección Y de prospectos) no traía teléfono — se agregaron
los campos `04 NUMERO` y `05 PREFIJO_PAIS` al CONCAT (después de `03 FC_ORDEN`, sin tocar los
índices existentes). El join de teléfono pasó de `LEFT JOIN T_CONTACTO_NUMERO/T_NUMERO` directo
(sin filtro, podía traer más de un número por contacto y duplicar filas) a `OUTER APPLY (SELECT
TOP 1 ... WHERE IB_ACTIVO = 1 ORDER BY FC_USUARIO_C DESC)` — mismo patrón que ya usaba la sección
de totales del mismo SP — para garantizar un solo número por lead.

```dart
// ProspectoHomeModel.fromRawString — índices nuevos
telefono:        ParseUtils.str(fields, 4),
prefijoTelefono: ParseUtils.str(fields, 5),
```

---

## Navegación desde Home

```dart
// A módulos principales (limpia stack)
context.goToSeguimiento()
context.goToPropuestas()
context.goToChats()
context.goToCobranza()

// A notificaciones
context.goToNotifications()

// A detalle de chat (construye stack correcto: Home limpio → ChatList → ChatDetail)
context.goToDetalleChatDesdeHome(idChatCab: prioridad.idChatCab)
```

---

## Notificaciones

| Ruta | `AppRoutes.notifications` |
|---|---|
| Transición | slideRight |
| Badge | `home.totNotificaciones` |

### `TipoNotificacion` — se resuelve por `T_NOTIFICACION_TIPO.CODIGO` (2026-07-20)

`NotificacionModel._parseTipo` (`data/models/notifications/notificacion_model.dart`) mapea el
`CODIGO` del SP `CSV_NOTIFICACIONES_LST_APP` a un `TipoNotificacion`. `'AIA'`/`'CHAT'` arman su
propia `descripcion` desde siempre (`_parseDatosChat`); `'RECORDATORIO'`/`'LEAD_POR_CONTACTAR'`/
`'LEAD_REASIGNADO'` ganaron su propio parseo del campo DATOS (antes cualquier código que no fuera
AIA/CHAT caía en `actividad` genérico y mostraba el DATOS crudo sin parsear, ilegible). Cualquier
código nuevo/desconocido (`GESTION_DE_CODIGO`, `GESTION_DE_PAGO`, `INSCRIPCION_DE_EMPRESAS`, y
futuros) sigue cayendo en `actividad` como fallback.

- **`RECORDATORIO`** (`_parseDatosRecordatorio`) — campos DATOS: `0 ID_RECORDATORIO`,
  `1 ASESOR_ASIGNADO`, `2 HORA_RECORDATORIO`, `3 NOM_ACCION`, `4 NOM_AVISO`, `5 MODALIDAD`,
  `6 FECHA_HORA_AVISO`, `7 COMENTARIO`, `8 NOM_CONTACTO`, `9 TELEFONO`, `10 ID_CONTACTO`
  (agregado al SP 2026-08-24, cierra el gap que documentaba esta sección — ver más abajo).
  Descripción: `"Tienes un recordatorio a las {hora}: {nom_accion}. Modalidad: {modalidad}"` —
  solo usa hora/acción/modalidad, `NOM_AVISO`/`COMENTARIO`/`NOM_CONTACTO`/`TELEFONO` quedan sin
  mostrar (pedido de negocio, texto exacto confirmado por el usuario). `idContacto` (índice 10)
  sí se extrae y alimenta "Ver seguimiento" igual que `LEAD_POR_CONTACTAR`/`LEAD_REASIGNADO`.
- **`LEAD_POR_CONTACTAR`** (`_parseDatosLeadPorContactar`) — campos DATOS: `0
  ASESOR_ASIGNADO_COD`, `1-5 DIA_SEMANA/DIA/MES/ANIO/HORA`, `6 NRO_DOCUMENTO`, `7 ID_LEAD`,
  `8 ID_CONTACTO`, `9 NOM_CONTACTO`, `10 DESC_CANAL`, `11 NOM_EMPRESA`, `12 TELEFONO`,
  `13 NOM_OPORTUNIDAD`, `14 NOM_ASESOR`. Descripción: `"Tienes una negociación por contactar con
  {nombre_contacto} sobre {oportunidad}, vía {canal}"`.
- **`LEAD_REASIGNADO`** (`_parseDatosLeadReasignado`) — mismo shape que `LEAD_POR_CONTACTAR` pero
  con `ASESOR_ANTERIOR_COD` intercalado en el índice `9`, así que todo lo que sigue corre un
  puesto: `9 ASESOR_ANTERIOR_COD`, `10 NOM_CONTACTO`, `11 NOM_EMPRESA`, `12 TELEFONO`,
  `13 NOM_OPORTUNIDAD`, `14 NOM_ASESOR_NUEVO`, `15 DESC_CANAL`, `16 NOM_ASESOR_REASIGNO` — **ojo,
  `DESC_CANAL` está en el índice 15 acá, no 10 como en `LEAD_POR_CONTACTAR`**, no reusar el mismo
  índice por error si se toca este parseo. Descripción: `"Tienes una negociación reasignada con
  {nombre_contacto} sobre {oportunidad}, vía {canal}"` — no usa `ASESOR_ANTERIOR_COD`/
  `NOM_ASESOR_NUEVO`/`NOM_ASESOR_REASIGNO` (quién reasignó a quién), solo el destino
  (contacto/oportunidad/canal), pedido de negocio.
- **`NotificacionTile`/`Notificacion`** (`presentation/widgets/notifications/tiles/`,
  `domain/entities/notifications/notificacion.dart`) — ícono/color/`etiquetaPrincipal`/
  `labelAccion` por tipo: `recordatorio` → `AppIcons.time` + `AppColors.warning` ("Recordatorio"),
  `leadPorContactar` → `AppIcons.phone` + `AppColors.info` ("Por contactar"), `leadReasignado` →
  `AppIcons.reasignar` + `AppColors.brandRaspberryAccessible` ("Reasignado").

### Chip "Actividades" + navegación a detalle de contacto (2026-08-24)

Pedido de negocio explícito: el chip "Actividades" agrupa todo lo que no es derivación (bot) ni
mensaje — `actividad` (genérico), `recordatorio`, `leadPorContactar`, `leadReasignado` — y el
botón "Ver seguimiento" de `leadPorContactar`/`leadReasignado` navega a detalle de contacto.

- **`NotificationsLoaded.actividades`** (`presentation/bloc/notifications/notifications_state.dart`)
  ahora filtra los 4 tipos de arriba, no solo `actividad` — antes recordatorio/por-contactar/
  reasignado solo aparecían en el chip "Todas". `derivaciones` (`AIA`) y `mensajes` (`CHAT`) sin
  cambios, cada uno sigue siendo su propio chip exclusivo.
- **`Notificacion.idContacto`** (nuevo campo `int?`, default `null`) — se parsea desde el índice
  `8` de DATOS (`ID_CONTACTO`, confirmado real con un CSV en vivo) en `_parseDatosLeadPorContactar`
  y `_parseDatosLeadReasignado` (`data/models/notifications/notificacion_model.dart`), ambos
  método pasaron de devolver `String` a `(String, int?)`. `null` en el resto de tipos.
- **`notifications_portrait.dart._onAccion`** — antes solo navegaba si `idChatCab != null`
  (mensaje/derivación) y no hacía nada para el resto. Ahora, si no hay `idChatCab`, cae a
  `context.goToDetalleContacto(idContacto:)` cuando `idContacto != null` (recordatorio/
  leadPorContactar/leadReasignado — `RECORDATORIO` sumó `ID_CONTACTO` al DATOS el mismo día,
  ver arriba, cerrando el gap que esta sección documentaba originalmente).
- **Solo `actividad` genérica sigue sin navegar** — el fallback (`GESTION_DE_CODIGO`/
  `GESTION_DE_PAGO`/`INSCRIPCION_DE_EMPRESAS`) no tiene parseo de DATOS definido en absoluto
  (se muestra crudo, sin formatear) ni trae ningún id de destino. Si negocio pide que también
  navegue, hay que definir su shape de DATOS en el SP primero.

### Marcar como leídas — automático y masivo (no selectivo)

Al entrar a la pantalla, `NotificationsBloc._onStarted` (`presentation/bloc/notifications/
notifications_bloc.dart`) carga la lista y dispara `unawaited(_marcarLeidas())`, que llama
`CSV_NOTIFICACIONES_CUD_APP` tarea `LE` — este SP hace `UPDATE ... SET IB_LEIDO = 1 WHERE
ID_USUARIO = @ID_USUARIO`, es decir marca **todas** las notificaciones del usuario como leídas de
una sola vez, no hay forma de marcar una individual. `NotificationsRefresh` (pull-to-refresh) no
vuelve a llamarlo. El estado ya emitido conserva el `leido` previo (por eso el punto azul se ve en
la visita actual y desaparece en la siguiente).

### Agrupación de mensajes por chat — `NotificacionModel._agruparMensajes` (2026-08-05)

Cada mensaje de WhatsApp entrante genera su propia fila en `T_NOTIFICACION`
(`CSV_WHATSAPP_CHAT_CUD_SP_V03`, tipo CHAT = `ID_TIPO_NOTIFICACION 5`) — una ráfaga de varios
mensajes seguidos del mismo chat llegaba como una tarjeta por mensaje. `NotificacionModel.parseList`
ahora agrupa después de parsear: todas las notificaciones con `tipo == TipoNotificacion.mensaje`
que comparten `idChatCab` se colapsan en una sola, usando los datos de la más reciente (la lista ya
viene ordenada `FC_USUARIO_C DESC` desde el SP) y una descripción con el conteo: `"{nombre} te ha
enviado {cantidad} mensajes nuevos para la oportunidad {oportunidad}."`. Si solo hay 1 notificación
para ese chat, se muestra el texto individual de siempre sin tocar.

- **Solo tipo mensaje (CODIGO `CHAT`)** — derivación (`AIA`) y el resto de tipos NO se agrupan,
  cada uno se sigue mostrando por separado (pedido explícito de negocio: aunque "Negociación
  derivada" comparta el mismo `idChatCab`/`ID_TIPO_NOTIFICACION 5` que los mensajes reales, debe
  quedar como su propia tarjeta).
- `NotificacionModel` ganó dos campos internos, `nombreCliente`/`oportunidad` (default `''`), solo
  para poder reconstruir el texto agrupado — no están en la entidad `Notificacion` (dominio) porque
  son un detalle de reconstrucción de texto del modelo, no algo que la UI necesite leer directo.
- `_parseDatosChat` pasó de devolver `(descripcion, idChatCab)` a `(descripcion, idChatCab,
  nombreCliente, oportunidad)` — cualquier otro caller nuevo de este método debe actualizar el
  destructuring.
- **Efecto colateral esperado, no un bug**: como el agrupamiento ocurre en `parseList` (antes de
  llegar al bloc/state), los contadores derivados (`NotificationsLoaded.mensajes.length`, chip
  "Mensajes", tarjeta "Mensajes sin leer" en `notifications_portrait.dart`) ahora cuentan
  conversaciones con mensaje nuevo, no mensajes individuales — es el comportamiento esperado tras
  agrupar, no requiere cambios adicionales en el bloc ni en la UI.
- `HomeRemoteDatasource.getNotifications()` y `NotificacionModel.parseList` cambiaron su tipo de
  retorno de `List<NotificacionModel>` a `List<Notificacion>` porque el ítem agrupado se construye
  con `Notificacion.copyWith` (definido en la clase base), no con el constructor de
  `NotificacionModel`.

### Destinatario explícito (por CODUSER) + oportunidad en el chip, no en el texto (2026-08-13)

Pedido de negocio: un moderador ve notificaciones de mensaje/derivación de todo su equipo (ver
"Filtro por usuario" abajo), pero el texto decía siempre "te ha enviado..." sin indicar a qué
asesor le llegó — ilegible para el moderador. El SP `CRM.CSV_NOTIFICACIONES_LST_APP` (tarea `LS`)
suma un campo `09` al CSV general (antes terminaba en `08: FC_USUARIO_C`) con **`NT.ID_USUARIO`
tal cual — el CODUSER crudo del destinatario, sin join a nombre** (decisión explícita del
usuario: descartó una primera versión que hacía `LEFT JOIN dbo.SYSMUSER01` para resolver el
nombre — el SP manda directo el código). `NotificacionModel.fromRawString` corrió sus índices de
campos fijos finales de 4 a 5 (`IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C, ID_USUARIO`) — cualquier
cambio futuro a esos campos fijos tiene que tocar `n - 5`...`n - 1` ahí, no solo el CONCAT del SP.

- **`NotificacionModel._esPropio(codUserDestinatario)`** compara ese CODUSER (case-insensitive,
  trim) contra `SessionService().codUser` (el usuario logueado) — decide el tono del texto:
  - **Propio** (viendo sus propias notificaciones, o un moderador viendo las suyas dentro del
    equipo) → texto de siempre con "te": `"{cliente} te ha enviado un mensaje."` /
    `"{cliente} te ha enviado {N} mensajes."` / `"Se te ha derivado {cliente}."`.
  - **Ajeno** (moderador viendo la notificación de otro asesor del equipo) → nombra al
    destinatario por su CODUSER, único dato disponible (no hay nombre resuelto):
    `"{cliente} le ha enviado un mensaje a {CODUSER}."` /
    `"{cliente} le ha enviado {N} mensajes a {CODUSER}."` /
    `"Se derivó a {cliente} hacia {CODUSER}."`.
  - Aplica a mensaje Y derivación por igual (`_parseDatosChat`), a diferencia de la agrupación
    (`_agruparMensajes`, ver abajo) que sigue siendo solo para mensaje.
- **Chip inferior = oportunidad, no el tipo** — `Notificacion.etiquetaPrincipal`
  (`domain/entities/notifications/notificacion.dart`) devuelve `oportunidad` para
  `mensaje`/`derivacion` en vez de "Mensaje"/"Derivación" fijos, siempre que `oportunidad` no
  esté vacía (si llega vacía, cae al label fijo de siempre). `oportunidad` se promovió de
  `NotificacionModel` (donde vivía como campo solo-interno) a la entidad base `Notificacion`
  porque la UI (`NotificacionTile`/`_ChipTipo`) la necesita después de que `_agruparMensajes` ya
  colapsó varias filas en una — `nombreCliente`/`codUserDestinatario` siguen siendo solo-internos
  de `NotificacionModel` (nunca los lee la UI directo, solo arman el texto).
- **Filtro por usuario/equipo — sin cambios, a propósito.** El moderador sigue viendo siempre el
  equipo completo en esta pantalla (`_session.isModerador ? 1 : 0` en
  `HomeRemoteDatasource.getNotifications()`), sin atarlo al filtro "Mi equipo / Mis casos"
  (`FiltroCubit`) que sí respeta el dashboard (`getData()`) — confirmado explícitamente por el
  usuario, no tocar esto sin pedido nuevo.

---

## Recarga en tiempo real — "Prioridad ahora"

`HomeBloc` se suscribe a `MessageDispatcher.instance.stream` (igual patrón que
`FiltroCubit.instance.stream`, ver constructor) y dispara `HomeRefresh()` cuando llega:

- `MENSAJE_WHATSAPP` — mensaje nuevo del cliente
- `NUEVO_LEAD_BOT` — lead nuevo creado por el bot

Ambos pueden calificar directo como "sin respuesta" en la sección de prioridades. No reacciona a
`UPDATE_PANTALLA_WHATSAPP` (confirmación de mensajes que envía el propio asesor) — eso no debe
disparar recarga. `HomeRefresh()` vuelve a pedir el dashboard completo (no hay parche en memoria
como en `ChatListBloc`), consistente con cómo ya reaccionaba al cambio de filtro del moderador.

### `HomeRefresh.silencioso` (2026-07-21)

`HomeRefresh` tiene un flag `silencioso` (default `false`) que controla si `_onRefresh` emite
`HomeLoading` antes de recargar:

- **`silencioso: true`** (recarga por `MENSAJE_WHATSAPP`/`NUEVO_LEAD_BOT` vía
  `MessageDispatcher`) — no emite `HomeLoading`, se queda en el `HomeLoaded` anterior mientras
  pide el dashboard de nuevo y lo reemplaza directo cuando llega. Así se ve como una
  actualización en tiempo real y no como una pantalla de carga completa.
- **`silencioso: false`** (default) — pull-to-refresh (`home_view.dart` `RefreshIndicator`),
  botón reintentar de `AppErrorView`, y el cambio de filtro del moderador
  (`FiltroCubit.instance.stream`) — estos sí muestran `HomeLoading` porque son acciones
  explícitas del usuario donde se espera feedback visual.

No se usa merge/patch en memoria para el caso silencioso (a diferencia de
`HomePrioridadGestionada`) porque el SP siempre trae el dashboard completo y armar un merge
parcial arriesga a dejar campos desactualizados si el SP omite alguna sección.