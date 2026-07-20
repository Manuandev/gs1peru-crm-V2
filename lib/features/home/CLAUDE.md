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