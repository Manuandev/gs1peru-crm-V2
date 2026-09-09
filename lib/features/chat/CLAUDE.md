# Feature: Chat

Gestiona conversaciones WhatsApp, envío de mensajes, multimedia, templates y edición de leads.
Es el feature más complejo de la app — leer completo antes de tocar cualquier archivo.

## `CRM.CSV_WHATSAPP_LST_APP` task `'LS'` — reescrito con tablas temporales + fin de duplicados (2026-09-09)

SP de la lista de chats (`NC.SQLChangeLock`, repo aparte — `.sql` UTF-16LE con BOM, preservar
la codificación). Antes el `FROM` arrancaba en `T_CONVERSACION_CAB` → **una fila por
conversación_cab**; como un número puede tener **más de una** conversación_cab (no debería pasar,
pero pasa), el mismo número salía **duplicado** en la lista.

- **`T_NUMERO` es ahora la jerarquía** (una fila por número). La conversación_cab se resuelve a
  **una sola**: la más reciente por número (`#ConversacionReciente`, `ROW_NUMBER() ... ORDER BY
  ID_CONVERSACION_CAB DESC`) — es la que viaja en el campo 34 (`ID_CONVERSACION_CAB`, el
  `idChatCab` que usa la app para abrir/enviar). `INNER JOIN #UltMsj` en el `SELECT` final
  descarta números sin **ningún** mensaje en ninguna de sus conversación_cab (equivale al
  `INNER JOIN` al último mensaje que tenía la versión vieja).
- **Los contadores/íconos de mensajes miran TODO el historial del número** — todas sus
  conversación_cab, no solo la reciente (pedido explícito de negocio): último mensaje (dir+fecha,
  campos 24/25 — antes salían solo de la conversación_cab del `FROM`), primer mensaje del cliente
  (27), derivado por IA (26), tipo/contenido/fecha del último mensaje del cliente (28/29/37),
  fecha del último mensaje IA (33) y cantidad de mensajes atendidos por la IA (32). Base común:
  `#DetNumero` (todos los `T_CONVERSACION_DET` de todas las conversación_cab de los números en
  scope) → 6 tablas derivadas con `ROW_NUMBER`/`GROUP BY`.
- **Estilo:** mismo patrón que `CRM.CSV_LEADS_LST_APP` task `'LS'` (tablas `#temp` +
  `CREATE UNIQUE CLUSTERED INDEX` + `ROW_NUMBER()`), en vez de ~10 `OUTER APPLY`/subqueries
  correlacionados por fila.
- **Contrato de salida:** mismos 38 campos y orden. Los campos **12-15 cambiaron de significado**
  (ver punto siguiente); el resto igual. `WITHIN GROUP (ORDER BY <último mensaje> DESC)` sin
  cambio.
- Tasks `'DT'`, `'LP'` **no se tocaron**. `'LU'` **sí** — ver los 2 puntos de abajo (mismos
  campos 12-15 + desempate del contacto). Pendiente el `ALTER PROCEDURE` en SSMS para desplegar.

### Estado y subestado SEPARADOS en `'LS'` + `'LU'` (2026-09-09)

`T_LEAD` ya guarda `ID_ESTADO` (estado real) e `ID_SUBESTADO` en columnas distintas. Antes el SP
los mezclaba: campo 12 = `ISNULL(SE.ID_ESTADO, LE.ID_ESTADO)` (el "leaf" — el subestado cuando
había), campo 14 = `IIF(sub, LE.ID_ESTADO, NULL)` (el padre). Ahora salen limpios:

| Campo | Antes | Ahora |
|---|---|---|
| 12 | leaf id (`ISNULL(SE.ID_ESTADO, LE.ID_ESTADO)`) | `LD.ID_ESTADO` — estado real (ej. `'04'`) |
| 13 | leaf desc | `LE.DESCRIPCION` — desc del estado |
| 14 | padre id (solo si hay sub) | `LD.ID_SUBESTADO` — subestado o `''` (ej. `'05'`) |
| 15 | padre desc | `SE.DESCRIPCION` — desc del subestado o `''` |

**Flutter en cadena:** `Chat.idEstadoPadre`/`descEstadoPadre` → **`idSubestado`/`descSubestado`**
(entidad + `ChatModel` + `copyWith` + `props`). `idEstado`/`descEstado` ahora son el estado real.
Los getters `idEstadoEfectivo`/`descEstadoEfectiva` se conservan como alias directos de
`idEstado`/`descEstado` (los call sites de `chat_tile.dart` no se tocaron). `_onLeadUpdated`
(`ChatListBloc`) traduce del `Negociacion` (que **sigue** con el encoding viejo leaf/padre) al
nuevo: `idEstado = lead.idEstadoEfectivo`, `idSubestado = haySub ? lead.idEstado : ''`.

### `'LS'` y `'LU'` resolvían un contacto distinto para el mismo número (2026-09-09)

Bug reportado: en la lista salía un nombre y al entrar al detalle salía otro. Ambos tasks
resuelven el contacto del número por "vínculo activo más reciente" en `T_CONTACTO_NUMERO`, pero
el `ORDER BY NC2.FC_USUARIO_C DESC` **no tenía desempate** — si el número tenía >1 contacto
activo con la misma fecha, `TOP 1` / `ROW_NUMBER()` devolvía uno distinto entre `'LS'` (lista) y
`'LU'` (detalle, `ChatDetailPage` lo re-resuelve por `idChatCab`). Corregido agregando
`, NC2.ID_CONTACTO_NUMERO DESC` como 2º criterio en ambos (mismo patrón que ya usan
`CSV_T_CONTACTO_LST` y otros SPs del repo).

## Lista de Conversaciones — retoques de UI (2026-09-09)

- **Título** (`chat_list_view.dart`): "Mis conversaciones" → **"Conversaciones"** (igual que el
  ítem del menú). El subtítulo "Ordenadas por última interacción" se mantiene.
- **Chip del bot** (`chat_tile.dart`, fila de acciones): el segundo `_ChipInfo` pasó de
  `label: 'Bot atendió N mensajes'` a `label: '$cantidadMensajesIA'` — solo el ícono del bot
  (`AppIcons.ia`) + el número. El chip ✨ "Derivado por IA" (`AppIcons.sparkle`, sin label) se
  deja como estaba.
- **"sin respuesta" movido a etiqueta abajo + nombre/número completos (`chat_tile.dart`).**
  El bloque `_InfoDerecha` de la fila principal no tenía ancho fijo: cuando el texto era
  "Esperando respuesta" (más largo que "sin respuesta") le robaba ancho al nombre y al número y
  los cortaba con "…". Cambios:
  - `_InfoDerecha` ahora **solo** muestra el tiempo desde el PRIMER mensaje del cliente
    (`fcPrimerMensajeCliente`). Se le quitó el 2º timer (`fechaHora`) y el texto
    "sin respuesta"/"Esperando respuesta".
  - Widget nuevo `_ChipSinRespuesta` (StatefulWidget, ticker de 1s como `_InfoDerecha`) — reusa
    `_ChipInfo` con `icon: AppIcons.accessTime`, `label: '<elapsed> sin respuesta'` /
    `'<elapsed> esperando respuesta'` (según `direccionMensaje == 'CLI'`), `fgColor` por
    `ElapsedTimeUtils.colorFromElapsed`, **fondo blanco (`AppColors.surface`) + borde suave
    (`AppColors.border`)** — a diferencia de los chips de IA que van sin borde y con fondo
    tintado. `_ChipInfo` ganó un `borderColor` opcional (null = sin borde, comportamiento previo).
    Se agrega al `Wrap` de la fila de acciones, después de los chips de IA (sale **siempre** que
    haya `fechaHora`, con o sin IA — por eso el `Wrap` ya no está envuelto en
    `if (chat.isDerivadoIA)`, los chips de IA pasaron a `if` internos).
  - `_InfoChat`: se quitó el recorte manual del nombre (`AppConstants.maxCharsNombreChat`,
    constante **eliminada** de `app_constants.dart` — solo se usaba acá) y el `Text` del nombre
    pasó de `maxLines: 1` a `maxLines: 2`. Con el ancho que liberó `_InfoDerecha`, nombre y
    número (fallback `'$prefijoPais $numero'`) se ven completos.

## Filtro avanzado de conversaciones — Campaña + Oportunidad en cascada (2026-09-08)

`FiltroChatDrawer` (`presentation/widgets/chat_list/filtro_chat_drawer.dart`) tiene combos
**Campaña** y **Oportunidad** en **cascada**, mismo criterio que "Editar negociación":
- Sin campaña elegida, el combo Oportunidad lista **todo** el catálogo
  (`CatalogsBloc.oportunidades`); con campaña elegida, solo las oportunidades de esa campaña
  (`o.idCampania.toString() == _campaniaId`).
- Al cambiar de campaña, si la oportunidad ya elegida no pertenece a la nueva campaña, se
  limpia (`_oportunidadId = ''`). El combo Oportunidad lleva `key: ValueKey('filtro-oportunidad-$_campaniaId')`
  para recrearse y resetear su texto visible (el `Autocomplete` interno de `CustomComboSearchField`
  no resincroniza su texto solo al cambiar `data`/`initialValue`).
- El catálogo completo lo garantiza el SP `CRM.CSV_LISTAS_LST_APP` (dejó de filtrar por vigencia
  de fecha — ver `lead/CLAUDE.md` y `core/CLAUDE.md`).

El filtrado de la lista es en memoria y **acumulativo (AND)**:
`ChatListBloc._aplicarFiltrosAvanzados` aplica primero campaña
(`Chat.idCampania.toString() == _filtroCampaniaId`) y luego oportunidad
(`Chat.idOportunidad.toString() == _filtroOportunidadId`) — campos 16/18 de `ConversationModel`.
El evento `ChatListFiltroAvanzadoAplicado` y `ChatListSuccess` llevan ambos ids
(`campaniaId`/`filtroCampaniaId`); `tieneFiltroAvanzado` los incluye. Si se agrega otro campo al
filtro, seguir el mismo patrón (evento → campo privado en el bloc → `_aplicarFiltrosAvanzados` →
estado).

## Negrita/cursiva/tachado en la lista de plantillas (2026-08-20)

Reportado por el usuario: un texto de plantilla con `*palabra*` se veía con los asteriscos
literales en `SelectTemplateModal` (tanto en `_TemplateItem`, la fila de la lista, como en
`_TemplatePreview`, el panel de vista previa), mientras que ese mismo texto sí se renderiza en
negrita real dentro del cuadrado de mensaje del chat. Causa: `_formatear()` (el helper local de
este archivo) siempre fue solo sustitución de variables (`{{nombre_cliente}}`, etc.) +
des-escape de `\n` — a propósito nunca hizo el parseo de formato WhatsApp, eso vivía únicamente
en `message_parser.dart` (`parseMensaje`), consumido solo por `message_bubble.dart`. Corregido
reusando `parseMensaje` en vez de duplicar su lógica: ganó un parámetro opcional `baseStyle`
(`TextStyle?`, default `AppTextStyles.bodyMedium` — mismo comportamiento de siempre para el
chat) para poder aplicarlo con el tamaño de texto que corresponda en cada lugar
(`labelSmall`/`bodySmall` en la lista de plantillas, en vez del `bodyMedium` fijo que traía
antes). Los dos `Text(contenidoFormateado, ...)` de `select_template_modal.dart` (`_TemplateItem`
y `_TemplatePreview`) pasaron a `Text.rich(TextSpan(children: parseMensaje(...)))` — `_formatear()`
sigue corriendo primero (variables + `\n`), su resultado ahora entra a `parseMensaje` en vez de
mostrarse como texto plano. Como beneficio adicional, las URLs dentro del texto de una plantilla
también quedan clicables en la vista previa, mismo comportamiento que ya tenía el chat.

## Nombre de archivo saneado antes de subir (2026-08-20)

Reportado por el usuario: una plantilla con un PDF adjunto llamado
`..._PLANTAS-NUTRICIO´N-EXPERIMENTO.pdf` (acento suelto/mal codificado antes de la N, no una
`Ñ`/`Ó` real) se guardaba bien en base de datos pero **la API de WhatsApp no entregaba el
documento al cliente**, sin error visible. Causa: el `fileName` viaja tal cual dentro del header
`Content-Disposition` del multipart (`ApiClient.postMultipart` → `MultipartFile.fromBytes(...,
filename: fileName)`, sin ningún tratamiento de codificación) y también como campo de texto en la
cabecera (`fileName`/`fileExt` unidos por `camp`) — un carácter fuera de ASCII seguro, sobre todo
uno ya roto (símbolo de acento sin letra), es la causa más común de que Meta rechace el mensaje en
silencio. Corregido en el único choque de ambos flujos: `ChatRemoteDatasource
.uploadAndSendFileMessage()` (envío de archivo suelto en el chat) y `.subirArchivoPlantilla()`
(adjunto de plantilla) — ambos sanean `fileName` con `sanitizarNombreArchivo`
(`core/utils/string/string_utils.dart`, ver `core/CLAUDE.md`) apenas entran al método, antes de
calcular `fileExt`/`cabecera` o pasarlo a `postMultipart`. La lista blanca es letras sin tilde,
números, `.`, `_`, `-` — cualquier otro carácter se elimina (no se reemplaza), sin importar si
viene de un acento normal, un acento roto, o un símbolo cualquiera. No se tocó el nombre en el
picker (`attachment_picker_widget.dart`/`template_form`) ni en base de datos — el saneo ocurre
solo en el punto de subida, así el usuario sigue viendo su nombre original en la UI de staging.

## 3 bugs reales de plantillas, reportados en vivo el mismo día (2026-08-20)

- **`idBoton` siempre viajaba en 0 al reenviar una plantilla por WhatsApp** — reportado con
  datos reales de `T_PLANTILLA_WHATSAPP_BOTON` (ids 1-4 no nulos) contra el log de
  `ENVIAR_WHATSAPP` mostrando `0¬SI¬0¬NO`. Causa: el task `'LP'` de `CSV_PLANTILLA_LST_APP`
  (lista, usado por `SelectTemplateModal` — la pantalla de ENVIAR una plantilla, no de editarla)
  solo mandaba el texto de cada botón (`STRING_AGG(TEXTO, @sepComodin)`), nunca su id real — a
  diferencia del task `'DP'` (editar), que sí manda `"idBoton¦texto"` desde siempre. Corregido en
  ambos lados: SP (`'LP'` ahora manda `CONCAT(ID_PLANTILLA_BOTON, @sepCampos, TEXTO)` por botón,
  unido por `@sepComodin`) y `PlantillaModel.fromRawString` (`template_model.dart`, rama
  `secciones.length <= 1` — parsea cada entrada del campo 9 como `id¦texto` en vez de texto
  plano). **Retrocompatible** — si el SP desplegado todavía manda solo texto (sin `¦`), el split
  da un solo token y cae a `idBoton=0`/`texto=ese token`, mismo comportamiento de antes.
- **Plantillas con audio ya guardado seguían permitiendo escribir descripción y agregar
  botones al editarlas** — la regla de exclusión mutua audio/texto/botones (ver más abajo,
  "Exclusión mutua...") ya estaba bien implementada, pero solo se activaba grabando audio NUEVO
  en la misma sesión. Causa: `_TemplateFormPortraitState.initState()` (`template_form_view.dart`)
  siempre inicializaba el `StagedFile` de un archivo ya guardado con `tipo: 'document'`
  hardcodeado — `Plantilla` no guarda el tipo real, solo ruta/nombre/ext. Corregido: el audio
  grabado siempre tiene extensión `.m4a` (única fuente de audio de este formulario, no hay
  "subir audio" como archivo suelto) — se usa esa extensión para resolver `tipo: 'audio'` vs
  `'document'` al cargar una plantilla existente.
- **Salto de línea (`\n`) se veía como texto literal en la vista previa de "Enviar plantilla"**
  — el contenido guardado trae el salto como texto literal (`\n`, a veces doble-escapado
  `\\n`), no como salto real. `select_template_modal.dart._formatear()` solo sustituía
  variables (`{{nombre_cliente}}`, etc.), nunca des-escapaba el salto — a diferencia de
  `message_parser.dart` (chat_detail/mensaje/), que ya hace este mismo unescape para los mensajes
  del chat. Se agregó el mismo `.replaceAll(r'\\n', '\n').replaceAll(r'\n', '\n')` a
  `_formatear()` (sin el resto del parseo de `message_parser.dart` — este preview es texto
  plano, no necesita negrita/URLs) — cubre tanto la card de la lista como el panel de vista
  previa, ambos llaman la misma función.

## Archivos clave

| Archivo | Qué hace |
|---|---|
| `data/datasources/remote/chat_remote_datasource.dart` | Toda la comunicación con API y SignalR |
| `data/models/chat_model.dart` | Lista de chats |
| `data/models/chat_message_model.dart` | Mensajes individuales |
| `data/models/info_lead_model.dart` | Detalle completo del lead |
| `data/models/template_model.dart` | Plantillas de WhatsApp |
| `data/repositories/chat_repository_impl.dart` | Delegación al datasource |
| `domain/repositories/chat_repository.dart` | Interfaz completa |

---

## BLoCs / Cubits — estructura de subcarpetas

| BLoC | Subcarpeta | Responsabilidad |
|---|---|---|
| `ChatListBloc` | `bloc/chat_list/` | Lista de chats con filtros y búsqueda |
| `ChatDetailBloc` | `bloc/chat_detail/` | Mensajes, estado de conversación, paginación |
| `EditLeadBloc` | `bloc/edit_lead/` | Formulario de edición de datos del lead |
| `InfoLeadCubit` | `bloc/info_lead/` | Estado reactivo del lead en el detalle del chat |
| `SelectTemplateBloc` | `bloc/template/` | Selección de template de WhatsApp |
| `TemplateFormBloc` | `bloc/template_form/` | Formulario crear/editar plantilla — ver sección propia abajo |

**`InfoLeadCubit` se comparte entre `ChatDetailPage` y `EditLeadPage`** — se crea en `ChatDetailPage` y se pasa a `EditLeadPage` con `BlocProvider.value`. No crear uno nuevo en `EditLeadPage`.

**`ChatListBloc` es la única excepción a "el bloc se crea en su Page y muere con ella"
(regla general de `features/CLAUDE.md`)** — vive **global**, provisto en
`app_widget.dart` junto a `AuthBloc`/`ThemeCubit`/`DrawerBloc`/`CatalogsBloc` (tabla que ese
mismo archivo tiene desactualizada, no lo lista). Motivo: se suscribe a
`MessageDispatcher.instance.stream` y a `LeadUpdateNotifier.instance.stream` para mantener
fresca la lista en memoria y el badge del drawer (`context.updateBadge`) en tiempo real
**aunque el usuario esté en otra pantalla** (Home, Seguimiento, etc.) — si muriera con
`ChatListPage`, esas suscripciones se cortarían cada vez que se sale de Conversaciones.
- **Bug real corregido (2026-07-30)**: como el bloc es global y solo dispara
  `ChatListStarted()` una vez al arrancar la app (`app_widget.dart`), `ChatListPage`
  (`StatelessWidget` sin `initState`) nunca volvía a pedir datos al reentrar — a diferencia
  de Seguimiento/Solicitudes/Cobranza, que sí recargan siempre porque su Page crea un Bloc
  nuevo (`BlocProvider(create: ...)`) en cada entrada. Corregido convirtiendo `ChatListPage`
  a `StatefulWidget` — su `initState()` dispara un evento de recarga a mano en cada entrada,
  simulando el mismo efecto de "recarga completa al entrar" sin tener que sacrificar el bloc
  global (que sigue vivo para el WebSocket/badge). Si se agrega otra pantalla con un bloc
  global por el mismo motivo (necesita seguir escuchando algo fuera de su propia página),
  replicar este patrón — `initState()` + evento de refresh — en vez de dejarla sin recarga.
- **Filtros "desde cero" al reingresar (2026-09-09)**: como el bloc es global, sus campos de
  filtro (`_filtroActivo` del chip, `_lastSearchQuery`, y los 5 del panel avanzado) sobrevivían
  al salir de la pantalla — el usuario ponía "En cobranza", iba a Inicio, volvía y el chip
  seguía activo. `initState()` ahora dispara **`ChatListReset`** (evento nuevo) en vez de
  `ChatListRefreshed`: `_onReset` limpia chip + búsqueda + panel avanzado a su valor inicial y
  recién ahí recarga. `ChatListRefreshed` se mantiene tal cual para pull-to-refresh y el botón
  de reintento del error — esos **sí** conservan el filtro activo.
- **"En cobranza" = cerrada ganada, no cualquier subestado '05' (2026-09-09)**: el chip/contador
  "En cobranza" filtraba `c.idEstado == '05'` — pero con el encoding viejo `idEstado` era el
  "leaf" (el subestado cuando existía), así que una negociación de cualquier padre con un
  subestado de id '05' pasaba el filtro (se veían chats con el chip "Nuevo" dentro de Cobranza).
  Con estado y subestado ya separados (ver arriba, "Estado y subestado SEPARADOS"), el helper
  `ChatListBloc._esEnCobranza(c)` quedó en **`c.idEstado == '04' && c.idSubestado == '05'`**,
  usado en los 3 lugares (`_calcularContadores`, `_calcularConteos`, `_aplicarFiltroChip`) para
  que no vuelvan a divergir. `conPropuesta` en esos mismos 3 lugares pasó de
  `idEstadoEfectivo == '02'` a `idEstado == '02'` (ahora `idEstado` ya es el estado real).

---

## Endpoints y códigos de operación

Todos los métodos usan `ApiConstants.urlChatsLst` o `ApiConstants.urlLeadsCud`:

| Código | Método | Endpoint |
|---|---|---|
| `D` | `getInfoLead(idLead)` | urlChatsLst |
| `L` | `getChats()` | urlChatsLst |
| `LD` | `getChatMessages(idLead, idUltimoMensaje?)` | urlChatsLst |
| `LP` | `getTemplates()` | urlPlantillasLst (`Wsp/SPPlantillaLSTApp` → `CRM.CSV_PLANTILLA_LST_APP`) |
| `DP` | `getPlantilla(idPlantilla)` | urlPlantillasLst — detalle para editar, con botones |
| `U` | `TemplateFormBloc.guardar(...)` → `guardarPlantilla(plantilla)` | urlPlantillasCud (`Wsp/SPPlantillaCUDApp` → `CRM.CSV_PLANTILLA_CUD_APP`) |
| — | `subirArchivoPlantilla(...)` | urlGuardarMultimediaPlantilla (`Wsp/GuardarMultimediaPlantilla`) — solo si hay un adjunto nuevo, antes de `U` |
| `UE` | `updateEstado(idLead, idEstado)` | urlLeadsCud |
| `U` | `updateLeadCompleto(lead)` | urlLeadsCud |
| `CA` | `sendWhatsAppMessage(...)` | SignalR |
| `CA` | `sendWhatsAppTemplateMessage(...)` | SignalR |

---

## Construcción del body

```dart
final sep  = AppConstants.sepListas;  // ¯
final camp = AppConstants.sepCampos;  // ¦

// Ejemplo: getInfoLead
final body = '${[idLead].join(camp)}${sep}D';

// Ejemplo: getChatMessages (con parámetro opcional)
final body = '${[idLead, idUltimoMensaje ?? ''].join(camp)}${sep}LD';

// Ejemplo: updateEstado (necesita IP del dispositivo)
final ip   = await _deviceInfo.getLocalIp();
final body = '${[idLead, idEstado, _session.codUser, ip].join(camp)}${sep}UE';
```

Helper para valores nulos o cero — centralizado en core, no duplicar por feature:
```dart
ParseUtils.orEmpty(val) // '' si val es null o 0, si no val.toString()
```

---

## Envío de mensajes — SignalR

Los mensajes NO se envían por HTTP. Se envían por SignalR:

```dart
SignalRService.instance.sendMessage("ENVIAR_WHATSAPP$sep$body")
// retorna bool — true si se envió al hub, no confirma entrega
```

### Mensaje de texto simple

```dart
bool sendWhatsAppMessage(
  String mensaje,
  String idLead,
  String numero,
  String chatCab,
)
// body = token ¯ [idLead, '', codUser, mensaje, 'text', numero, 0, '', chatCab, '', '', '', codUser, ''] ¯ CA
```

### Mensaje con template

```dart
bool sendWhatsAppTemplateMessage({
  required Template template,
  required String mensajeFormateado,
  required String idLead,
  required String numero,
  required String chatCab,
  required String nombreCliente,
  required String apellidoCliente,
  required bool isExpirado,   // si true → VAR07 = '1' (reabre conversación)
  required bool isCerrado,    // si true → VAR07 = '1'
})
// 17 variables (VAR01–VAR17) separadas por camp, encabezadas por token + sep + ... + sep + CA
```

**VAR07** controla si la conversación está expirada/cerrada — siempre verificar ambas flags.

**VAR17 — botones de la plantilla, agregado 2026-08-18** (antes el envío por socket se quedaba
en VAR16, sin mandar los botones en sí). Formato `id¬texto¬id¬texto...` — **todo** unido por
`sepRegistros` (`¬`), nunca por `sepCampos` (`¦`). Vacío si `plantilla.botones` está vacío.
- **Bug real corregido el mismo día, detectado en vivo por el usuario con un log real del
  socket**: la primera versión unía cada par `idBoton¦texto` con `camp` (`¦`) — copiando el
  patrón de `guardarPlantilla()`, donde ese formato SÍ es seguro porque vive dentro de su propia
  sección `¯` aparte. Acá NO — VAR17 es un campo más dentro de la MISMA lista plana
  `VAR01..VAR17` que se une con `camp` un nivel más arriba, así que cualquier `¦` embebido
  adentro de VAR17 corre todos los VAR posteriores un campo. Repro real: un botón con
  `idBoton=0` y texto `"3"` se mandó como `"...¦1¦0¦3¯CA"` — el `0¦3` (id y texto del botón)
  quedó indistinguible de dos VAR sueltos, y el lado que lee el mensaje terminó viendo solo
  `"3"` donde esperaba el bloque de botones completo. Corregido uniendo id y texto de cada
  botón (aplanado, sin distinguir "dentro de un botón" de "entre botones") con `sepRegistros`
  en vez de `camp` — coincide con la notación `id¬texto¬id¬texto...` que ya traía la tabla del
  contrato, que en su momento se leyó mal como "separador `¬` entre pares `id¦texto`" en vez de
  "separador `¬` para todo, sin `¦` en ningún lado de VAR17".
Confirmado contra la tabla real del contrato `Gs1WebSocket` que compartió el usuario:

| Var | Campo | Notas |
|---|---|---|
| VAR01 | idConversacion | |
| VAR02 | nombrePlantilla | |
| VAR03 | codasesor | |
| VAR04 | mensaje (ya con `{{}}` sustituidas) | esto es lo que realmente se envía como texto |
| VAR05 | `template` | fijo para este flujo |
| VAR06 | celular destino | |
| VAR07 | 0/1 | ⚠️ ver nota abajo |
| VAR08 | — | vacío, no usado |
| VAR09 | idChatCabecera | |
| VAR10 | — | vacío, no usado |
| VAR11 | nombreLead | |
| VAR12 | apellidoLead | |
| VAR13 | nombre asesor | |
| VAR14 | contenido crudo de la plantilla (con `{{}}`) | solo referencia/registro |
| VAR15 | archivo adjunto | vacío si no tiene |
| VAR16 | 1 si tiene botones | |
| VAR17 | botones `id¬texto¬id¬texto...` | separador `¬` para todo, no `¯` ni `¦` |

**VAR07 — confirmado con el usuario (2026-08-18), sin cambios de código.** La duda que dejó la
tabla del contrato (*"debe ser 0 — si es 1 (chat cerrado), Gs1WebSocket rechaza el envío"*) se
resolvió: VAR07 debe reflejar el estado REAL del chat (abierto/cerrado) — el código actual
(`isExpirado || isCerrado ? '1' : '0'`) ya hace exactamente eso, es el comportamiento correcto.
La nota de la tabla no era "siempre manda 0" sino la advertencia por defecto para el caso normal
(chat abierto); cuando el chat sí está cerrado/expirado, `'1'` es el valor correcto — es
justamente lo que le permite al socket reabrirlo al enviar una plantilla.

---

## Subida de multimedia — chunks

Para imágenes, videos y documentos. Endpoint: `ApiConstants.urlGuardarMultimedia`.

```dart
Future<bool> uploadAndSendFileMessage({
  required String filePath,
  required String fileName,
  required String tipo,    // 'image' | 'video' | 'document' | 'audio'
  required String idLead,
  required String numero,
  required String chatCab,
})
```

**Flujo interno:**

```
1. Leer bytes del archivo completo
2. Si fileBytes.isEmpty → return false

3. Calcular extensión desde fileName (lastIndexOf('.'))

4. Construir cabecera:
   [idLead, '', codUser, '', tipo, numero, 0, '', chatCab, fileName, fileExt]
   separados por camp

5. Dividir en chunks de 2MB (2 * 1024 * 1024)
   totalChunks = (totalSize / chunkSize).ceil()

6. Por cada chunk i:
   dataString = [token, cabecera, '', 'C', i, totalChunks].join(sep)
   postMultipart(fields: {'data': dataString}, fileBytes: chunk)
   → response.split(camp)[0] debe ser 'OK' — si no, return false

7. Llamada de merge (ensambla chunks en el servidor):
   mergeData = [token, cabecera, '', 'C', totalChunks, totalChunks].join(sep)
   postMultipart(fileBytes: [])  ← vacío, solo indica fin
   → response.split(camp)[0] debe ser 'OK'
```

---

## ChatRepository — interfaz completa

```dart
// Consultas
Future<InfoLead> getInfoLead(int idLead)
Future<List<Chat>> getChats()
Future<List<ChatMessage>> getChatMessages(int idLead, {String? idUltimoMensaje})
Future<List<Template>> getTemplates()

// Escritura
Future<CrudResult> updateEstado(int idLead, String idEstado)
Future<CrudResult> updateLeadCompleto(InfoLead lead)

// SignalR — sincrónicos, retornan bool
bool sendWhatsAppMessage(String mensaje, String idLead, String numero, String chatCab)
bool sendWhatsAppTemplateMessage({...})

// Multimedia — asincrónico
Future<bool> uploadAndSendFileMessage({...})
```

---

## Carga de mensajes — paginación

```dart
// Primera carga
getChatMessages(idLead)                          // idUltimoMensaje = null

// Cargar más antiguos (scroll hacia arriba)
getChatMessages(idLead, idUltimoMensaje: '123')  // id del mensaje más antiguo visible
```

---

## Templates — selector con retorno de valor

La ruta `AppRoutes.templates` retorna `Template?`:

```dart
// Navegar y esperar selección
final template = await context.goToTemplates(lead: lead);
if (template != null) {
  // usar template seleccionado
}
```

Template tiene: `nombre`, `detalle`, `rutaArchivo`, `nombreArchivo`,
`extensionArchivo`, `isBoton`.

---

## Gestión de plantillas — crear/editar (solo vista, 2026-07-24)

`TemplateFormPage`/`TemplateFormView` (`presentation/pages/template_form_page.dart`,
`presentation/widgets/chat_detail/template_form/`) — formulario para crear o editar una
plantilla, agregado dentro de `chat/` (no hay ni habrá una feature `whatsapp/` aparte — decisión
explícita del usuario: "plantillas está dentro de la conversación, no voy a hacer algo aparte").

**Entradas** — ambas desde `select_template_modal.dart`:
- Botón "Nuevo" (ícono `+`) en el header, junto al botón de cerrar → `context.goToTemplateForm()`.
- Botón "Editar" en `_TemplatePreview`, debajo de la plantilla seleccionada →
  `context.goToTemplateForm(idPlantilla: plantilla.idPlantilla)`.

**Campos del formulario** (`Plantilla` — nuevos campos de gestión, todos con default para no
romper el flujo de envío que ya usaba la entidad): `idCampania`, `idOportunidad`,
`idEstadoNegociacion` (id de `EstadoItem`, el catálogo general de estados de negociación —
**no confundir con `activo`**, son dos campos distintos aunque el mockup original los mezclaba
en uno solo), `activo` (bool), `compartir` (bool), `botones` (`List<String>`, solo el texto de
cada botón — no hay tipos de botón como quick-reply/URL/teléfono).

- Campaña → Oportunidad en cascada, mismo patrón que
  `edit_lead_portrait.dart._onOportunidadChanged` (filtra `oportunidades.where((o) =>
  o.idCampania == campania.id)`).
- Estado usa `CatalogsBloc.estados.where((e) => e.esPadre)`, igual que
  `edit_lead_negociacion_section.dart`.
- Adjuntos: imagen/documento se suben con `image_picker`/`file_picker` (como
  `attachment_picker_widget.dart`); audio se graba con `AudioRecorderWidget` (ya existente en
  `widgets/chat_detail/audio/`) — no hay opción de subir un audio ya grabado, hay que grabarlo.
  El archivo queda en un `StagedFile` local, se muestra con `TemplateFileCard` (ver abajo).
- Descripción: toolbar con negrita/cursiva/tachado (`AppIcons.boldText/italicText/
  strikethroughText`, envuelven la selección con `*`/`_`/`~`, formato WhatsApp) + botón
  "+ Variable" que inserta `{{nombre_cliente}}`/`{{apellido_cliente}}`/`{{nombre_asesor}}` en el
  cursor — mismas 3 variables que ya reemplaza `_formatear` en `select_template_modal.dart`.

**`TemplateFileCard`** (`widgets/chat_detail/template/template_file_card.dart`) — card de
archivo adjunto con ícono/color por extensión (centralizado en
`core/utils/ui/file_type_utils.dart` — `fileIcon`/`fileColor`, ya extendido con imagen/audio) +
nombre + extensión. Reemplaza al viejo `_ArchivoChip` de una sola línea (pedido del jefe: "un
poco más grande, con más información"). `compact: true` da la versión chica en fila, usada en
`_TemplateItem` (lista lateral angosta); el default (cuadrado grande, `AppSizing.fileCardSize`)
se usa en `_TemplatePreview`. `detailed: true` (agregado 2026-08-09) da una tercera versión en
fila — ícono cuadrado + nombre en negrita + "EXT · peso" debajo (`sizeBytes`, peso formateado con
`file_type_utils.dart.formatFileSize`) + botón de quitar como ícono simple a la derecha (no el
círculo rojo superpuesto del cuadrado default) — es la que usa
`TemplateFormAdjuntosSection` para mostrar el archivo ya adjuntado en el formulario, junto con el
texto de ayuda "Solo se permite un archivo por plantilla — sube uno nuevo para reemplazarlo."
debajo de la card.

**Reglas de negocio confirmadas (2026-07-24):**
- Tope de botones: **6** sin archivo adjunto, **3** con archivo adjunto (imagen/documento/audio)
  — `_maxBotones` en `template_form_view.dart`, recalculado según `_archivo`. Al bajar el tope
  (por adjuntar un archivo) los botones ya agregados no se recortan solos — el límite solo
  bloquea agregar más.
- No se puede adjuntar un archivo si ya hay más de 3 botones agregados (`_puedeAdjuntar`) — el
  círculo de subir queda deshabilitado y gris hasta que se borren botones. Quitar el archivo
  vuelve a subir el tope a 6 automáticamente (ambos son getters derivados de `_archivo`/
  `_botonesCtrls`, no hay que sincronizar nada a mano).
- Negrita/cursiva/tachado (`_envolverSeleccion`) también funcionan sin texto seleccionado:
  insertan el par de marcadores con el cursor al medio, listo para escribir — no solo envuelven
  una selección existente.
- Toolbar de Descripción: negrita/cursiva/tachado/variable — sin emojis (quitados a pedido del
  usuario, 2026-08-18; el picker en grid y `AppIcons.emoji` que usaba ya no están en este
  toolbar).

**Alcance actual (actualizado 2026-07-29) — guardar, listar y cargar para editar ya son reales:**
- `CRM.CSV_PLANTILLA_CUD_APP` (task `'U'`, repo `NC.SQLChangeLock`) crea o actualiza
  `CRM.T_PLANTILLA_WHATSAPP` + reemplaza por completo (borrar/insertar) `T_PLANTILLA_WHATSAPP_BOTON`/
  `_ARCHIVO` en cada guardado — no hace diff, manda el estado completo del formulario cada vez.
  `TIPO_PLANTILLA`/`IB_EDITABLE` (columnas nullable de `T_PLANTILLA_WHATSAPP`) y `ID_META`/
  `ESTADO_META` no los toca el formulario — esos dos últimos los puebla la sincronización con Meta,
  no la app.
- **Botones — update en sitio por id, corregido de verdad el 2026-08-18 (la entrada de abajo,
  fechada "2026-08-09", describía este mismo diseño pero nunca había llegado a escribirse en el
  `.sql` real — quedó como documentación de una intención, no de un hecho).** Bug real
  reportado por el usuario: al ver una plantilla con botones en la lista de envío
  (`SelectTemplateModal`) aparecía un solo botón con el texto "1"; al editarla, los campos de
  texto de los botones mostraban "1"/"0" en vez del texto real ("Sí"/"No", etc.). Causa
  encontrada al releer `CRM.CSV_PLANTILLA_CUD_APP.sql` completo: el bloque BOTONES del task
  `'U'` todavía tenía la versión ingenua original — `STRING_SPLIT(@L_DATA_BTN, @sepRegistros)`
  tratando cada botón como texto plano — pero Flutter (`ChatRemoteDatasource.guardarPlantilla`)
  ya mandaba cada botón como `idBoton¦texto` (con el separador de campos embebido). El SP
  guardaba ese string completo tal cual en la columna `TEXTO` (ej. `TEXTO = "0¦Sí"`) — al leerlo
  de vuelta, `CONCAT(idReal, sepCampos, TEXTO)` quedaba con un `¦` de más, y el `.split(sepCampos)`
  del lado Flutter (`PlantillaModel.fromRawString`) partía en 3 en vez de 2 — `texto` terminaba
  siendo el `idBoton` embebido (`"0"`, `"1"`, etc.) en vez del texto real, que se perdía.
  **Fix real, ahora sí escrito en el `.sql`**: el bloque BOTONES pasó a leer `@L_DATA_BTN` con
  `[dbo].[Fnsplitstringtable15](..., @sepRegistros, @sepCampos)` (mismo splitter que ya usa la
  cabecera) en vez de `STRING_SPLIT` — separa `idBoton` y `texto` de verdad antes de tocar la
  tabla. Con eso: `DELETE` solo de los `ID_PLANTILLA_BOTON` que ya no vienen en la lista actual;
  `UPDATE` en sitio (`TEXTO`/`ORDEN`) de los que traen id real (`≠0`); `INSERT` (PK manual
  `MAX+1`, no `IDENTITY`) solo de los nuevos (`id=0`). El comentario de la declaración de
  `@L_DATA_BTN` (que también describía el formato viejo, "sin tipos ni ids") se corrigió de
  paso. **Cualquier plantilla guardada mientras el `.sql` viejo estaba desplegado quedó con
  `TEXTO` corrupto** (el id embebido en vez del texto real) — ese dato ya guardado no se
  corrige solo con este fix; si el usuario reporta plantillas viejas con botones "1"/"0", hay
  que re-guardarlas desde el formulario una vez este `.sql` esté desplegado (el `UPDATE` en
  sitio va a sobreescribir el `TEXTO` corrupto con el real que el asesor vea/confirme en el
  formulario esa vez). Sigue pendiente el `ALTER PROCEDURE` en SSMS.

  Estructura del lado Flutter (sin cambios en esta sesión, ya estaba lista desde antes —
  solo el `.sql` le faltaba llegar a calzar con esto): `Plantilla.botones` es
  `List<PlantillaBoton>` (`idBoton` + `texto`, no `List<String>`) — cada botón viaja
  `idBoton¦texto` (id `0` = nuevo, campo aparte del cuerpo principal, registros separados por
  `sepRegistros`). `CSV_PLANTILLA_LST_APP` (task `'DP'`) devuelve `@BOTONES` como
  `idBoton¦texto¬idBoton¦texto...` (no solo `texto¬texto...`) — necesario para que el formulario
  sepa qué id mandar de vuelta al reabrir una plantilla para editar.
  `_TemplateFormPortraitState` (`template_form_view.dart`) mantiene `_botonesIds` en paralelo a
  `_botonesCtrls` (mismo índice) — `_agregarBoton`/`_quitarBoton` mutan ambas listas juntas;
  `_guardar()` arma `PlantillaBoton(idBoton: _botonesIds[i], texto: ...)` por cada controller con
  texto no vacío. El **archivo** adjunto sigue con el criterio viejo (borrar + insertar si llega
  uno nuevo, sin id de ida y vuelta) — decisión explícita del usuario, no se tocó.
- **Archivo adjunto — subida real, orquestada al presionar "Guardar plantilla" (no al elegir el
  archivo)**: `TemplateFormBloc.guardar(plantilla, {archivoLocal})` — si `archivoLocal` no es
  `null` (el usuario eligió/grabó un archivo en esta sesión, todavía con path LOCAL del
  dispositivo), primero lo sube (`SubirArchivoPlantillaUseCase` → `ChatRemoteDatasource.
  subirArchivoPlantilla`, mismo mecanismo por chunks de 2MB que `uploadAndSendFileMessage`) y
  recién con la ruta/nombre/ext REALES que devuelve el servidor arma la plantilla a guardar
  (`Plantilla.copyWith`); si no hay archivo nuevo (sin adjunto, o el que ya traía la plantilla al
  editar, sin tocarlo), guarda directo sin pasar por la subida. Esta decisión (subir-antes-de-
  guardar vs guardar-directo) vive en el Bloc a propósito, no en el evento — `guardar()` no es un
  event handler porque la vista necesita el `CrudResult` al toque para decidir si vuelve atrás o
  se queda mostrando el error sin perder lo tipeado.
  - Endpoint dedicado `Wsp/GuardarMultimediaPlantilla` (`WspController.cs`) — variante de
    `GuardarMultimediaWhatsApp` sin `idLead`/`idChatCab` (una plantilla no pertenece a ninguna
    conversación) ni notificación SignalR al terminar. Guarda **plano** en
    `<FileServer>\ARCHIVOS_WSP\PLANTILLAS` (se crea si no existe, sin subcarpeta por plantilla —
    pedido explícito del usuario) — el nombre final en disco lleva un prefijo `uploadToken_`
    (token generado en Flutter, `DateTime.now().microsecondsSinceEpoch`, viaja igual en todos los
    chunks de una misma subida) para no pisar otro archivo con el mismo nombre y para que los
    chunks temporales de subidas simultáneas no choquen. `ARCHIVO_TOKEN` (columna NOT NULL de
    `T_PLANTILLA_WHATSAPP_ARCHIVO`) lo sigue generando el SP con `NEWID()`, es un dato aparte del
    prefijo del nombre de archivo.
  - Si `archivoNombre` llega vacío al SP, solo borra el archivo anterior de esa plantilla sin
    insertar uno nuevo — así es como se "quita" un adjunto ya guardado.
- `getTemplates()`/`getPlantilla()` apuntan a `ApiConstants.urlPlantillasLst` (`Wsp/
  SPPlantillaLSTApp`, endpoint dedicado — antes usaban el genérico `urlChatsLst`) y
  `guardarPlantilla()`/`subirArchivoPlantilla()` a `urlPlantillasCud`/`urlGuardarMultimediaPlantilla`
  — los 3 métodos nuevos en `WspController.cs` son passthrough puro (mismo patrón que
  `SPWhatsappLSTApp`) salvo `GuardarMultimediaPlantilla`, que sí tiene lógica propia de archivos
  (igual que `GuardarMultimediaWhatsApp`, del que es variante).
- **Detalle para editar — ya real.** `CRM.CSV_PLANTILLA_LST_APP` ganó la rama `'DP'` (antes solo
  tenía `'LP'`): devuelve los mismos 9 campos base + los 5 de gestión (`idCampania`/
  `idOportunidad`/`idEstadoNegociacion`/`activo`/`compartir`) + una sección aparte (separada por
  `sepListas`) con los botones (`STRING_AGG` de `TEXTO` ordenado por `ORDEN`, separados por
  `sepRegistros`). `PlantillaModel.fromRawString` ahora separa esa sección extra antes de parsear
  los campos — compatible con `'LP'` (nunca trae `sepListas`, así que el split no le afecta).
  `TemplateFormBloc._onStarted` en modo editar ya llama `GetPlantillaUseCase` de verdad.
- No define tipos de botón (quick-reply/URL/teléfono) — solo texto libre por botón.
- **`SelectTemplateModal` (lista/preview de envío) — texto vacío se oculta + botones visibles
  (2026-08-18).** `_TemplateItem` (lista lateral) y `_TemplatePreview` (panel derecho) ya no
  muestran la burbuja/línea de texto si `plantilla.contenido` (formateado) queda vacío tras
  `_formatear` — una plantilla puede ser solo archivo y/o botones, sin contenido de texto.
  `_TemplatePreview` arma sus 3 bloques opcionales (texto/archivo/botones) en una lista y
  intercala el espaciado solo entre los que sí aplican (`for (var i = 0; i < bloques.length;
  i++)`), en vez de dejar huecos fijos cuando falta alguno.
  Nuevo widget privado `_BotonesPreview` (chips con `AppIcons.tap` + texto, borde
  `colorScheme.primary`) — muestra `plantilla.botones` en ambos lugares (`compact: true` en la
  lista, tamaño normal en el preview), mismo criterio "solo texto, sin tipos" que
  `TemplateFormBotonesSection`.
  **`Plantilla.botones` ahora también llega en la lista (task `'LP'`), no solo al editar
  (`'DP'`)** — antes `getTemplates()` solo traía `tieneBoton` (bool). `CRM.CSV_PLANTILLA_LST_APP`
  (`NC.SQLChangeLock`, repo aparte — `.sql` UTF-16LE con BOM, cualquier edición debe preservar la
  codificación) ganó un campo 09 con los textos de los botones unidos por `sepComodin` (`¨`, "uso
  libre") — no puede reusar `sepRegistros`/`sepListas` como hace `'DP'` porque `sepRegistros` ya
  separa cada PLANTILLA dentro de la lista completa (`STRING_AGG(..., @sepRegistro)`); usar ese
  mismo separador para una lista anidada de botones rompería el split de nivel superior. El campo
  08 (`tieneBoton`) pasó de comparar `TOP 1 ID_PLANTILLA` a derivarse del mismo `STRING_AGG` de
  botones (`CASE WHEN BT.BOTONES IS NOT NULL THEN 1 ELSE 0 END`) — una sola `OUTER APPLY`, sin
  necesidad de 2 subconsultas. `PlantillaModel.fromRawString` distingue el campo 9 de 'LP'
  (comodin-joined, sin id) del campo 9 de 'DP' (`idCampania`, sin relación) por
  `secciones.length > 1` — 'DP' siempre trae la sección de `sepListas` (aunque el `@BOTONES` de
  esa rama venga vacío), 'LP' nunca la trae, así que no hay ambigüedad real entre ambos formatos.
  Botones parseados desde 'LP' llevan `idBoton: 0` (de solo lectura, no hace falta id para
  mostrarlos acá) — no confundir con los de 'DP', que sí lo necesitan para el guardado en sitio
  del formulario. Pendiente correr el `ALTER PROCEDURE` en SSMS para desplegar el `.sql` a la
  base real.
- **La lista ya no se refresca al solo entrar/salir del formulario sin guardar + confirma
  salir con cambios sin guardar (2026-08-18).** Dos bugs reportados juntos por el usuario:
  1. `SelectTemplateModal._abrirFormulario()` llamaba `SelectTemplateRefresh()` siempre al
     volver de `TemplateFormPage`, sin importar si el usuario guardó algo o solo canceló/
     retrocedió — la lista de plantillas se recargaba del backend en cada entrada al
     formulario, aunque no hubiera pasado nada. Fix: `goToTemplateForm()`
     (`navigation_extensions.dart`) pasó de `Future<void>` a `Future<bool?>` —
     `RouteDefinition<bool>` en `app_router.dart` — y `_TemplateFormPortraitState._guardar()`
     hace `context.goBack(true)` solo en el caso `CrudOk()`; Cancelar/retroceder siguen
     usando `context.goBack()` sin argumento (`null`). `_abrirFormulario()` ahora solo agrega
     `SelectTemplateRefresh()` si `guardo == true`.
  2. Al cambiar cualquier valor del formulario (crear o editar) y presionar Cancelar o
     retroceder (AppBar/gesto físico), ahora sale un diálogo de confirmación — antes salía
     directo sin avisar, perdiendo lo tipeado en silencio. Mismo patrón que
     `SolicitudWizardView._confirmarSalir` (`solicitudes/CLAUDE.md`): snapshot inicial
     (`_snapshotInicial`, armado al final de `initState()` con `_construirPlantilla()` — método
     nuevo, extraído de lo que antes armaba `_guardar()` inline) comparado por `Equatable`
     (`Plantilla` ya lo era) contra el formulario actual (`_hayCambios`, getter). Sin cambios,
     `_confirmarSalir()` sale directo; con cambios, muestra `context.showConfirmDialog(...)` y
     solo sale si se confirma. Conectado en 2 puntos: `FormSaveBar.onCancelar` (llamada
     directa — un `Navigator.pop()` explícito no pasa por `PopScope`) y un `PopScope`
     (`canPop: !_hayCambios`) envolviendo el `Stack` raíz de `build()` (cubre el back del AppBar
     y el gesto/botón físico, ambos vía `Navigator.maybePop`, que sí respeta `PopScope`).
- **Nombre, Campaña y Oportunidad obligatorios; Estado NO (2026-08-18).** Mismo criterio que
  `EditLeadPortrait._camposObligatoriosCompletos`/`_puedeGuardar` (`lead/CLAUDE.md`): labels con
  sufijo `(*)` en `TemplateFormGeneralSection` (Nombre plantilla/Campaña/Oportunidad — Estado se
  queda sin `(*)`) + getter derivado `_camposObligatoriosCompletos` en
  `_TemplateFormPortraitState` que gatea `FormSaveBar.isEnabled` y un guard temprano en
  `_guardar()`. `_nombreCtrl` ganó el mismo listener `_onFormChanged` que ya tenían
  `_contenidoCtrl`/`_botonesCtrls` para que el botón Guardar reaccione en vivo mientras se
  tipea el nombre, no solo al perder foco.
- **Exclusión mutua audio/texto/botones (2026-08-18).** Reglas de negocio confirmadas por el
  usuario, implementadas en `_TemplateFormPortraitState` (`template_form_view.dart`) con 3
  getters derivados (`_hayDescripcion`, `_archivoEsAudio`, `_bloqueadoPorAudio =
  _grabandoAudio || _archivoEsAudio`) que las 3 secciones hijas reciben como props:
  - Con texto ya escrito en la descripción, la opción "Grabar audio" del bottom sheet de
    adjuntos queda deshabilitada (`TemplateFormAdjuntosSection.puedeGrabarAudio`) — no se puede
    enviar audio junto con texto.
  - Mientras se graba audio o ya hay uno adjunto (`_bloqueadoPorAudio`), el campo Descripción
    queda de solo lectura (`TemplateFormDescripcionSection.enabled`) y la sección Botones entera
    se bloquea — inputs existentes deshabilitados y "Agregar botón" deshabilitado
    (`TemplateFormBotonesSection.bloqueadoPorAudio`).
  - Un botón nuevo solo se puede agregar si hay descripción escrita
    (`TemplateFormBotonesSection.hayDescripcion`) y ningún botón ya agregado quedó con el texto
    vacío — evita crear un botón en blanco antes de completar el anterior.
  - `_contenidoCtrl` y cada controller de `_botonesCtrls` llevan un listener
    (`_onFormChanged` → `setState(() {})`) para que estas reglas reaccionen en vivo mientras se
    tipea, no solo al perder foco — antes ningún controller de este formulario tenía listener
    propio, la UI no reaccionaba a cambios de texto en tiempo real.
- **Overlay de guardado — `AppProcessOverlay` (2026-08-09).** `_TemplateFormPortraitState` en
  `template_form_view.dart` replica el mismo patrón de 2 pasos que `EditLeadPortrait` (ver
  `core/CLAUDE.md` → `AppProcessOverlay` y `lead/CLAUDE.md` → "Overlay de guardado/éxito"):
  `_guardando` (ya existía) + `_mostrandoExito` (nuevo) controlan un único
  `if (_guardando || _mostrandoExito) AppProcessOverlay(...)` al final del `Stack` que envuelve
  el `build()`. En el caso `CrudOk()` de `_guardar()`, en vez de `context.goBack()` inmediato,
  ahora hace `setState(() => _mostrandoExito = true)` → espera 1.5s → recién ahí vuelve atrás —
  mismo timing que `EditLeadPortrait._guardar()`. El mensaje de carga/éxito varía por
  `widget.plantilla.idPlantilla == 0` (crear vs editar), igual criterio que allá. Como
  `TemplateFormBloc.guardar()` ya orquesta subida de archivo + CUD en una sola llamada (ver
  arriba), este único overlay cubre ambos pasos sin distinguir "subiendo archivo" de "guardando
  plantilla" — no hace falta un tercer estado intermedio.

---

## Edición de lead — Cubit compartido

`EditLeadPage` recibe el `InfoLeadCubit` ya creado desde `ChatDetailPage`:

```dart
// Navegar pasando el cubit existente
context.goToEditarLead(lead: lead, cubit: context.read<InfoLeadCubit>());

// El router lo envuelve con BlocProvider.value — no crea uno nuevo
```

Campos editables en `updateLeadCompleto`:
`idEstado`, `idCampania`, `idEvento`, `idCanal`, `idInteres`

---

## Selector de multimedia — `WhatsAppMediaPicker`

```dart
// Navegar y esperar assets seleccionados
final assets = await context.goToMediaPicker();
// retorna List<AssetEntity>? — null si canceló
```

Ruta: `AppRoutes.mediaPicker` con `TransitionType.slideRight`.

---

## Páginas y rutas

| Página | Ruta | Transición | Argumentos |
|---|---|---|---|
| `ChatListPage` | `AppRoutes.chats` | material | — |
| `ChatDetailPage` | `AppRoutes.detalleChat` | slideRight | `{'idChatCab': int}` — resuelve el `Chat` completo internamente vía task `LU`, sin importar el origen (lista de chats, lista de leads, home) |
| `EditLeadPage` | `AppRoutes.detalleEditarLead` | slideRight | `{'lead': InfoLead, 'cubit': InfoLeadCubit}` |
| `SelectTemplatePage` | `AppRoutes.templates` | slideRight | `{'lead': InfoLead}` |
| `TemplateFormPage` | `AppRoutes.templateForm` | slideRight | `{'idPlantilla': int?}` — null = crear, con valor = editar |
| `WhatsAppMediaPicker` | `AppRoutes.mediaPicker` | slideRight | — |

---

## Estados de conversación

Una conversación puede estar:
- **Expirada** (`isExpirado = true`) — ventana de 24h cerrada, solo templates
- **Cerrada** (`isCerrado = true`) — lead en estado "Cerrado"
- **Tiempo de chat abierto vencido** — ver abajo, bloquea todo (ni texto ni templates)
- **Activa** — envío libre de texto y multimedia

Siempre verificar ambas flags (`isExpirado`/`isCerrado`) antes de permitir envío de texto libre.

### Tiempo de chat abierto (TDE) — `ChatInputBar`

Independiente de `isExpirado`/`isCerrado`. Se calcula en el cliente, en
`ChatInputBar` (`presentation/widgets/chat_detail/chat_input_bar.dart`):
compara `Chat.fcPrimerMensajeCliente` (fecha del primer mensaje del cliente)
contra `ConfiguracionService().tiempoChatAbierto` (grupo `TDE`, opción
`idTiempoChatAbierto = 1`, valor en **horas**). Si ya se superó, se reemplaza
toda la barra (texto, mic, adjuntar y plantillas) por `_TiempoVencidoBar` —
a diferencia de la barra de "Expirada", aquí no se ofrece reabrir con
plantilla. Un `Timer.periodic` de 1 minuto reevalúa mientras el chat está
abierto, para bloquear sin necesidad de reingresar a la pantalla.