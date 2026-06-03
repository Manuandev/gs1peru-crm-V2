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

## Endpoints y códigos de operación

Todos los métodos usan `ApiConstants.urlChatsLst` o `ApiConstants.urlLeadsCud`:

| Código | Método | Endpoint |
|---|---|---|
| `D` | `getInfoLead(idLead)` | urlChatsLst |
| `L` | `getChats()` | urlChatsLst |
| `LD` | `getChatMessages(idLead, idUltimoMensaje?)` | urlChatsLst |
| `LP` | `getTemplates()` | urlChatsLst |
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

Helper para valores nulos o cero:
```dart
String _orEmpty(dynamic val) =>
    (val == null || val == 0) ? '' : val.toString();
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
| `ChatDetailPage` | `AppRoutes.detalleChat` | slideRight | `{'idLead': int}` |
| `EditLeadPage` | `AppRoutes.detalleEditarLead` | slideRight | `{'lead': InfoLead, 'cubit': InfoLeadCubit}` |
| `SelectTemplatePage` | `AppRoutes.templates` | slideRight | `{'lead': InfoLead}` |
| `WhatsAppMediaPicker` | `AppRoutes.mediaPicker` | slideRight | — |

---

## Estados de conversación

Una conversación puede estar:
- **Expirada** (`isExpirado = true`) — ventana de 24h cerrada, solo templates
- **Cerrada** (`isCerrado = true`) — lead en estado "Cerrado"
- **Activa** — envío libre de texto y multimedia

Siempre verificar ambas flags antes de permitir envío de texto libre.