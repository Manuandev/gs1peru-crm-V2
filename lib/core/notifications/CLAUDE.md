# Notificaciones — lib/core/notifications

Dos flujos paralelos que confluyen en `LocalNotificationService` para mostrar la notificación al usuario.

---

## Flujo 1 — Foreground / Background via SignalR

```
Backend → SignalR hub
    └─ SignalRService.onMessage
        └─ WebSocketMessageParser.parse(raw)
            └─ MessageDispatcher.dispatch(wsMessage)
                ├─ MENSAJE_WHATSAPP → _dispatchWhatsApp → NotificationHandler.show
                │       └─ LocalNotificationService.showWhatsApp(leadId, mensaje)
                └─ NUEVO_LEAD      → _dispatchLead     → NotificationHandler.show
                        └─ LocalNotificationService.showLeadNuevoNotification(wsMessage)
```

**Supresión foreground:**
- `MENSAJE_WHATSAPP` se suprime si el usuario está en `AppRoutes.chats` o en el chat específico (`activeLeadId == leadId`).
- `NUEVO_LEAD` se suprime si el usuario está en `AppRoutes.seguimiento`.

---

## Flujo 2 — Background/Killed via FCM

```
Backend (C# FcmService.EnviarAsync)
    └─ data["cuerpo"] = string crudo SignalR  (ej: "NUEVO_LEAD±campo1¦campo2¬...")
    └─ notification.body = mismo string crudo

App killed → firebaseMessagingBackgroundHandler (isolate separado)
    ├─ Firebase.initializeApp()
    ├─ LocalNotificationService.instance.initBackground()
    ├─ WebSocketMessageParser.parse(data["cuerpo"])
    │       └─ WebSocketMessage(process, records, receivedAt)
    ├─ NUEVO_LEAD      → LocalNotificationService.showLeadNuevoNotification(parsed)
    └─ MENSAJE_WHATSAPP → LocalNotificationService.showChatNotification(parsed)
                              └─ delega a showWhatsApp(leadId, mensaje)
```

**Key importante:** el backend manda el body en `data["cuerpo"]`, no en `data["body"]`.

---

## Tap en notificación

### App en foreground o background (app viva)
`onDidReceiveNotificationResponse` → `NotificationNavigator.navigateWithAction(notif, actionId: response.actionId)`

### App killed (cold start desde notificación)
Llamar desde Splash (cuando el navigator key ya está activo):
```dart
await NotificationNavigator.instance.handleLocalNotificationLaunch();
```
Internamente usa `getNotificationAppLaunchDetails()` y llama `navigateWithAction`.

### Resolución de actionId

| actionId | Destino |
|---|---|
| `'ver_lead'` | `AppRoutes.seguimiento` → push `AppRoutes.detalleSeguimiento` con `{idLead: int}` |
| `'abrir_conversacion'` | `AppRoutes.chats` → push `AppRoutes.detalleChat` con `{idLead: String}` |
| `null` (tap en body) | `navigate(notif)` — ruta según `notif.route` |

---

## LocalNotificationService — métodos

| Método | Descripción |
|---|---|
| `init()` | Inicialización completa con canal Android. Llamar en `main()`. |
| `initBackground()` | Igual que `init()` pero sin pedir permisos. Llamar en el handler FCM. |
| `requestPermissions()` | Pide permiso de notificaciones. Llamar desde Splash con UI visible. |
| `show(AppNotification)` | Notificación genérica con ID timestamp (no agrupa). |
| `showWhatsApp({leadId, mensaje})` | Notificación agrupada por `leadId` con InboxStyle. ID = leadId. |
| `showLeadNuevoNotification(WebSocketMessage)` | Notificación con BigText + botones "Ver lead" y "Abrir conversación". ID = leadId (reemplaza). |
| `showChatNotification(WebSocketMessage)` | Parsea con `WhatsAppMessagePayload` y delega a `showWhatsApp`. |
| `clearLead(int leadId)` | Cancela notificación y limpia historial de mensajes del lead. |
| `cancelAll()` | Cancela todas las notificaciones. Llamar al logout. |

---

## NotificationNavigator — métodos

| Método | Descripción |
|---|---|
| `navigate(AppNotification)` | Navega según `notif.route`. |
| `navigateWithAction(notif, {actionId})` | Navega considerando `actionId` del botón de acción. |
| `handleLocalNotificationLaunch()` | Async. Detecta cold start desde notificación local y navega. |

---

## Canales Android

| Canal | ID | Importancia |
|---|---|---|
| CRM Notificaciones | `app_crm_channel` | Max |

---

## Procesos soportados

| Proceso SignalR | Foreground | Background/Killed |
|---|---|---|
| `NUEVO_LEAD` | ✅ via MessageDispatcher → NotificationHandler | ✅ via FCM background handler |
| `MENSAJE_WHATSAPP` | ✅ via MessageDispatcher → NotificationHandler | ✅ via FCM background handler |

---

## Agregar proceso nuevo

1. `MessageDispatcher.dispatch()` → agregar case y método `_dispatchXxx`
2. `NotificationHandler.parse()` → agregar case y método `_parseXxx`
3. `LocalNotificationService` → agregar método `showXxxNotification` si necesita UI especial
4. `firebaseMessagingBackgroundHandler` → agregar case para el proceso
5. `NotificationNavigator` → agregar lógica de navegación si tiene actionId nuevo
6. Actualizar esta tabla
