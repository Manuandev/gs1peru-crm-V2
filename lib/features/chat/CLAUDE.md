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