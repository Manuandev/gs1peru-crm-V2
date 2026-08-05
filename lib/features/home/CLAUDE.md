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

```dart
final campos = totalesRaw.split(AppConstants.sepCampos); // ¦
int t(int i) {
  if (i >= campos.length) return 0;
  final v = campos[i].trim();
  return v.isEmpty ? 0 : int.tryParse(v) ?? 0;
}

// Índices:
t(0) → totConversaciones
t(1) → totProspectos
t(2) → totPropuestas
t(3) → totCobranza
t(4) → totLeadsNuevos
t(5) → totLeadsDesarrollo
t(6) → totNotificaciones
```

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
  `6 FECHA_HORA_AVISO`, `7 COMENTARIO`, `8 NOM_CONTACTO`, `9 TELEFONO`. Descripción:
  `"Tienes un recordatorio a las {hora}: {nom_accion}. Modalidad: {modalidad}"` — solo usa hora/
  acción/modalidad, `NOM_AVISO`/`COMENTARIO`/`NOM_CONTACTO`/`TELEFONO` quedan sin mostrar (pedido
  de negocio, texto exacto confirmado por el usuario).
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
  `AppIcons.reasignar` + `AppColors.brandRaspberryAccessible` ("Reasignado"). Los 3 muestran el
  botón de acción ("Ver seguimiento") igual que `actividad` — ninguno de los 4 tiene todavía un id
  de destino propio para navegar (mismo pendiente que ya tenía `actividad`, ver
  `notifications_portrait.dart._onAccion`).
- **Pendiente, no tocado**: los chips de filtro de `notifications_portrait.dart`
  (`_Filtro.todas/actividades/derivaciones/mensajes`, `NotificationsLoaded.actividades/
  derivaciones/mensajes`) siguen sin un chip dedicado para estos 3 tipos nuevos — aparecen en
  "Todas" pero ya no caen bajo el chip "Actividades" (antes sí, porque todo lo no-AIA/CHAT caía
  ahí). Si negocio pide un chip propio para Recordatorios/Por contactar/Reasignados, agregar el
  getter correspondiente a `NotificationsLoaded` y su `_FiltroChip` en `notifications_portrait.dart`.

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