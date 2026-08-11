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
                │       └─ LocalNotificationService.showWhatsApp(idNumero, idChatCab, numero, mensaje)
                ├─ NUEVO_LEAD      → _dispatchLead     → NotificationHandler.show
                │       └─ LocalNotificationService.showLeadNuevoNotification(wsMessage)
                └─ NUEVO_LEAD_BOT  → _dispatchLeadBot  → NotificationHandler.show
                        └─ LocalNotificationService.showLeadNuevoBotNotification(wsMessage)
```

**Supresión foreground:**
- `MENSAJE_WHATSAPP` se suprime si el usuario está en `AppRoutes.chats` o en el chat específico (`activeLeadId == leadId`, sigue siendo id de lead — no confundir con el `idNumero` que agrupa la notificación).
- `NUEVO_LEAD` se suprime si el usuario está en `AppRoutes.seguimiento`.
- `NUEVO_LEAD_BOT` nunca se suprime — siempre se muestra.

**Filtro por destinatario (`NotificationHandler._parseWhatsApp`, 2026-07-31):** `MENSAJE_WHATSAPP`
solo se muestra si `codAsesor` (payload) coincide con `SessionService().codUser` — un asesor o
supervisor con la app abierta nunca debe ver el push del chat de otro asesor. `NUEVO_LEAD_BOT` no
tiene este filtro — sí debe llegarle tanto al asesor asignado como a su supervisor (el backend en
`GS1Peru-SocketCore` ya replica esta misma regla del lado FCM con `incluirSupervisores`, ver
`FcmService.EnviarAsync` — ese repo es el dueño real de a quién le llega el push cuando la app está
cerrada; este filtro de acá cubre el caso con la app abierta, donde el broadcast de SignalR llega
sin distinción de destinatario a todos los conectados).

---

## Flujo 2 — Background/Killed via FCM

```
Backend (C# FcmService.EnviarAsync)
    └─ data["cuerpo"] = string crudo SignalR  (ej: "NUEVO_LEAD±campo1¦campo2¬...")
    └─ notification.body = mismo string crudo

App killed → firebaseMessagingBackgroundHandler (isolate separado)
    ├─ Firebase.initializeApp()
    ├─ LocalNotificationService.instance.initBackground()
    ├─ LocalDatabase().init()
    ├─ _haySesionRestaurable() → si es false, corta acá — no muestra nada
    ├─ WebSocketMessageParser.parse(data["cuerpo"])
    │       └─ WebSocketMessage(process, records, receivedAt)
    ├─ NUEVO_LEAD      → LocalNotificationService.showLeadNuevoNotification(parsed)
    ├─ NUEVO_LEAD_BOT   → LocalNotificationService.showLeadNuevoBotNotification(parsed)
    └─ MENSAJE_WHATSAPP → LocalNotificationService.showChatNotification(parsed)
                              └─ delega a showWhatsApp(idNumero, idChatCab, numero, mensaje)
```

**Key importante:** el backend manda el body en `data["cuerpo"]`, no en `data["body"]`.

**Gate de sesión restaurable (`_haySesionRestaurable`, en `firebase_notification_service.dart`):**
con la app cerrada no hay sesión en memoria — si el Splash no va a poder restaurar sola la sesión
guardada (lee la tabla `session`: necesita `remember_me = 1` o `login_type = 'google'`, misma regla
que `AuthRepositoryImpl.tryRestoreSession`), no se muestra ninguna notificación. Evita que el
usuario toque una notificación y caiga en un chat/lead sin token válido. **Solo aplica a este
handler** — SignalR y el listener foreground de FCM (`_procesarMensaje`) nunca necesitan este gate,
porque si están corriendo es porque `AuthBloc` ya está en `AuthAuthenticated` (sesión viva en
memoria, independiente de si `remember_me` está marcado).

---

## Tap en notificación

### App en foreground o background (app viva)
`onDidReceiveNotificationResponse` → `NotificationNavigator.navigateWithAction(notif, actionId: response.actionId)`

### App killed (cold start desde notificación)
```dart
await NotificationNavigator.instance.handleLocalNotificationLaunch();
```
Internamente usa `getNotificationAppLaunchDetails()` y llama `navigateWithAction`. Ni el tap en el
cuerpo ni el tap en un botón (aunque tenga `showsUserInterface: true`) pasan por
`onDidReceiveNotificationResponse` cuando la app estaba totalmente cerrada — es una limitación
documentada del plugin ("This callback cannot be used to handle when a notification launched an
app"). Este método es el único lugar donde ese tap inicial se puede leer, para los dos casos
(cuerpo y botón).

**Conectado en `app_widget.dart`**, dentro del `BlocListener<AuthBloc, AuthState>`, justo después
de `context.goToHome()` en la rama `AuthAuthenticated` — no antes, porque necesita
`SessionService().hasSession` ya poblado (para la guardia de `_goChat`/`_goLead`) y Home ya en la
base del stack para poder apilar el detalle encima. Trae un guard interno (`_launchProcesado`) para
no reprocesar el mismo cold-start launch si `AuthAuthenticated` se repite en el mismo proceso (ej.
logout y volver a loguear sin cerrar la app).

### Resolución de actionId

| actionId | Destino |
|---|---|
| `'ver_lead'` | `AppRoutes.seguimiento` → push `AppRoutes.detalleSeguimiento` con `{idLead: int}` |
| `'abrir_conversacion'` | `AppRoutes.chats` → push `AppRoutes.detalleChat` con `{idChatCab: int}` (mismo helper `_goChat` que `'abrir_conversacion_bot'`) |
| `'ver_negociacion_bot'` | `_goSeguimiento` → `AppRoutes.detalleContacto` con `{idNumero: int}` — el backend agregó `idNumero` como campo [5] de `NUEVO_LEAD_BOT` (confirmado en producción 2026-07-16) |
| `'abrir_conversacion_bot'` | `AppRoutes.chats` → push `AppRoutes.detalleChat` con `{idChatCab: int}` |
| `null` (tap en body) | `navigate(notif)` — ruta según `notif.route` |

**Todos los `AndroidNotificationAction` llevan `showsUserInterface: true`.** Sin ese flag,
Android despacha el tap del botón a `onDidReceiveBackgroundNotificationResponse` (isolate en
background) en vez de `onDidReceiveNotificationResponse` — y ese callback de background está
vacío (`_onBackgroundTap` en `local_notification_service.dart`), así que el botón parecía "no
hacer nada". Con el flag, el tap siempre pasa por el callback de foreground y sí navega.

---

## LocalNotificationService — métodos

| Método | Descripción |
|---|---|
| `init()` | Inicialización completa con canal Android. Llamar en `main()`. |
| `initBackground()` | Igual que `init()` pero sin pedir permisos. Llamar en el handler FCM. |
| `requestPermissions()` | Pide permiso de notificaciones. Llamar desde Splash con UI visible. |
| `show(AppNotification)` | Notificación genérica con ID timestamp (no agrupa). |
| `showWhatsApp({idNumero, idChatCab, numero, mensaje, nombreCliente?})` | Notificación agrupada por `idNumero` (no por lead — un número puede pasar por varios leads) con InboxStyle. Título "Nombre - numero" si hay `nombreCliente`, si no solo `numero`, con "(N mensajes)" si hay más de uno. `MENSAJE_WHATSAPP` hoy no trae nombre del cliente en la trama, así que siempre cae en el título solo-número hasta que se agregue esa fuente de datos. El desplegable muestra como máximo `_maxMensajesVisibles` (3) mensajes más recientes — el contador del summary sí refleja el total real acumulado. Toda la notificación (colapsada o expandida) es un único tap target → abre `AppRoutes.detalleChat` de ese `idChatCab`, igual para cualquier mensaje visible ya que todos pertenecen a la misma conversación. ID = idNumero. Los mensajes acumulados se persisten en SQLite (`settings`, clave `notif_msgs_{idNumero}`, valor = mensajes unidos con `AppConstants.sepRegistros`) — no en memoria, porque el handler de FCM en background corre en un isolate nuevo por cada push con la app cerrada y un `Map` en memoria perdería el conteo entre uno y otro. Antes de sumar, consulta `getActiveNotifications()` — si no hay una notificación activa con ese `id` (el usuario la descartó con swipe, o es la primera vez), arranca el historial de cero en vez de seguir sumando al de `settings`; si no, el contador quedaba "pegado" en el último total aunque el usuario ya la hubiera descartado. |
| `showLeadNuevoNotification(WebSocketMessage)` | Notificación con BigText + botones "Ver lead" y "Abrir conversación". ID = leadId (reemplaza). |
| `showLeadNuevoBotNotification(WebSocketMessage)` | Parsea con `NuevoLeadBotPayload` (6 campos: idLead, codAsesor, nombreCliente, numero, idChatCab, idNumero). El backend manda esta misma trama al asesor asignado y a su supervisor (`incluirSupervisores`, ver arriba) — el título/cuerpo cambia según quién la reciba: compara `payload.codAsesor` contra el `cod_user` propio leído de SQLite (tabla `session`, no `SessionService()` — vacío en el isolate de FCM background). Si `esDestinatario` (soy el asesor asignado): "Te asignaron una nueva conversación derivada por el bot" / "Por favor, atiéndela a la brevedad." Si no (soy supervisor viendo la derivación de otro asesor): "Se derivó una conversación al asesor {codAsesor}" / "Podrás darle el seguimiento desde el detalle." — muestra el código, no el nombre: la trama no trae el nombre del asesor y el catálogo de asesores no está persistido en SQLite para resolverlo en background. Botones "Ver negociación" (`ver_negociacion_bot`) y "Abrir conversación" (`abrir_conversacion_bot`) — iguales para ambos casos, los dos navegan. ID = idLead (reemplaza). |
| `showChatNotification(WebSocketMessage)` | Parsea con `WhatsAppMessagePayload` y delega a `showWhatsApp`. |
| `clearLead(int idNumero)` | Async. Cancela la notificación y borra la clave `notif_msgs_{idNumero}` de `settings`. Llamar al entrar al detalle de ese chat (`ChatDetailBloc._onStarted`). |
| `cancelAll()` | Cancela todas las notificaciones. Se llama desde `AuthBloc._onLogoutRequested` (`auth_bloc.dart`) — evita que una notificación que quedó en la bandeja se toque después del logout y navegue sin sesión. |

---

## NotificationNavigator — métodos

| Método | Descripción |
|---|---|
| `navigate(AppNotification)` | Navega según `notif.route`. |
| `navigateWithAction(notif, {actionId})` | Navega considerando `actionId` del botón de acción. |
| `_goChat` / `_goLead` (privados) | Antes de navegar, verifican `SessionService().hasSession` — si no hay sesión activa, redirigen a `AppRoutes.login` en vez de abrir el chat/lead. Respaldo por si una notificación vieja sobrevive a un logout o el gate de FCM background no aplica (ej. tap con la app todavía viva). |
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
| `NUEVO_LEAD_BOT` | ✅ via MessageDispatcher → NotificationHandler | ✅ via FCM background handler |
| `MENSAJE_WHATSAPP` | ✅ via MessageDispatcher → NotificationHandler | ✅ via FCM background handler |

---

## Agregar proceso nuevo

1. `MessageDispatcher.dispatch()` → agregar case y método `_dispatchXxx`
2. `NotificationHandler.parse()` → agregar case y método `_parseXxx`
3. `LocalNotificationService` → agregar método `showXxxNotification` si necesita UI especial
4. `firebaseMessagingBackgroundHandler` → agregar case para el proceso
5. `NotificationNavigator` → agregar lógica de navegación si tiene actionId nuevo
6. Actualizar esta tabla
