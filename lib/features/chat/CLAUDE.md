# Feature: Chat

Gestiona conversaciones WhatsApp, envío de mensajes, multimedia, templates y edición de leads.
Es el feature más complejo de la app — leer completo antes de tocar cualquier archivo.

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
  a `StatefulWidget` — su `initState()` dispara `ChatListRefreshed()` a mano en cada entrada,
  simulando el mismo efecto de "recarga completa al entrar" sin tener que sacrificar el bloc
  global (que sigue vivo para el WebSocket/badge). Si se agrega otra pantalla con un bloc
  global por el mismo motivo (necesita seguir escuchando algo fuera de su propia página),
  replicar este patrón — `initState()` + evento de refresh — en vez de dejarla sin recarga.

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
// 16 variables (VAR01–VAR16) separadas por camp, encabezadas por token + sep + ... + sep + CA
```

**VAR07** controla si la conversación está expirada/cerrada — siempre verificar ambas flags.

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
- Toolbar de Descripción incluye emojis (`AppIcons.emoji`, picker propio en grid, sin dependencia
  nueva) además de negrita/cursiva/tachado/variable.

**Alcance actual (actualizado 2026-07-29) — guardar, listar y cargar para editar ya son reales:**
- `CRM.CSV_PLANTILLA_CUD_APP` (task `'U'`, repo `NC.SQLChangeLock`) crea o actualiza
  `CRM.T_PLANTILLA_WHATSAPP` + reemplaza por completo (borrar/insertar) `T_PLANTILLA_WHATSAPP_BOTON`/
  `_ARCHIVO` en cada guardado — no hace diff, manda el estado completo del formulario cada vez.
  `TIPO_PLANTILLA`/`IB_EDITABLE` (columnas nullable de `T_PLANTILLA_WHATSAPP`) y `ID_META`/
  `ESTADO_META` no los toca el formulario — esos dos últimos los puebla la sincronización con Meta,
  no la app.
- **Botones — update en sitio por id (2026-08-09), ya no borrar+reinsertar todos en cada
  guardado.** `Plantilla.botones` es `List<PlantillaBoton>` (`idBoton` + `texto`, no
  `List<String>`) — cada botón viaja `idBoton¦texto` (id `0` = nuevo, campo aparte del cuerpo
  principal, registros separados por `sepRegistros`). `CSV_PLANTILLA_CUD_APP` (task `'U'`) ahora
  hace `DELETE` solo de los que ya no vienen en la lista (se quitaron en el formulario), `UPDATE`
  en sitio de los que traen id (texto/orden), e `INSERT` (PK manual `MAX+1`, no `IDENTITY`) solo
  de los nuevos (id `0`) — antes borraba y reinsertaba TODOS con id nuevo en cada guardado,
  aunque solo se hubiera tocado un carácter de un botón ya existente. De paso se cambió el split
  de `STRING_SPLIT` a `fnSplitStringTable15` (mismo método que ya usa la cabecera del SP) — el
  orden ya no depende de `STRING_SPLIT`, que no lo garantizaba (viejo TODO de esta misma nota,
  ya resuelto). `CSV_PLANTILLA_LST_APP` (task `'DP'`) devuelve `@BOTONES` como
  `idBoton¦texto¬idBoton¦texto...` (antes solo `texto¬texto...`) — necesario para que el
  formulario sepa qué id mandar de vuelta al reabrir una plantilla para editar.
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