# Navegación y Rutas — lib/config

Todo lo relacionado a rutas, navegación y transiciones vive en `lib/config/router/`.

---

## Archivos y responsabilidades

| Archivo | Qué contiene |
|---|---|
| `router/app_routes.dart` | Constantes string de todas las rutas |
| `router/app_router.dart` | Registry de rutas + lógica de transiciones |
| `router/navigation_extensions.dart` | Extensions de `BuildContext` para navegar + `NavigationService` |

---

## AppRoutes — `router/app_routes.dart`

Nunca hardcodear strings de rutas. Siempre usar estas constantes.

```dart
// Auth
AppRoutes.splash           // '/'
AppRoutes.login            // '/login'
AppRoutes.changePassword   // '/cambiar-contrasena'

// Principales
AppRoutes.home             // '/home'
AppRoutes.settings         // '/settings'
AppRoutes.chats            // '/chats'
AppRoutes.seguimiento      // '/seguimiento'
AppRoutes.propuestas       // '/propuestas'
AppRoutes.cobranza         // '/cobranza'

// Home
AppRoutes.notifications    // '/home/notifications'

// Chats
AppRoutes.detalleChat          // '/chats/detalle'
AppRoutes.detalleEditarLead    // '/chats/detalle/editar-lead'
AppRoutes.templates            // '/chats/templates'

// Seguimiento / Propuestas / Cobranza
AppRoutes.detalleSeguimiento   // '/seguimiento/detalle'
AppRoutes.detallePropuesta     // '/propuestas/detalle'
AppRoutes.detalleCobranza      // '/cobranza/detalle'

// Utilidades
AppRoutes.mediaPicker          // '/media-picker'
```

**Convención de nombrado:**
- Módulos raíz: `/modulo`
- Sub-rutas: `/modulo/accion`
- Sub-sub-rutas: `/modulo/seccion/accion`

---

## AppRouter — `router/app_router.dart`

### Tipos de transición

```dart
TransitionType.material    // transición por defecto Flutter
TransitionType.fade        // fade in/out 300ms — Login, Splash
TransitionType.slideRight  // slide desde derecha 300ms — detail pages
```

### RouteDefinition

Cada ruta es un `RouteDefinition` con builder y transición:

```dart
AppRoutes.miRuta: RouteDefinition(
  builder: (context) => MiPage(),
  transition: TransitionType.slideRight,
),

// Con argumentos obligatorios
AppRoutes.miRuta: RouteDefinition(
  transition: TransitionType.slideRight,
  builder: (context) {
    final args = _requireArgs<Map<String, dynamic>>(context);
    return MiPage(param: args['param']);
  },
),

// Con valor de retorno tipado
AppRoutes.miRuta: RouteDefinition<MiTipo>(
  transition: TransitionType.slideRight,
  builder: (context) {
    final args = _requireArgs<Map<String, dynamic>>(context);
    return MiPage(lead: args['lead'] as InfoLead);
  },
),
```

### Ruta de error

Si una ruta no existe, se muestra una pantalla 404 automáticamente y redirige a Home.

---

## Navigation Extensions — `router/navigation_extensions.dart`

Usar siempre las extensions de contexto. Nunca `Navigator.of(context).pushNamed(...)` directamente.

### Rutas críticas — limpian el stack completo

```dart
context.goToLogin()
context.goToHome()
```

### Módulos principales — limpian el stack

```dart
context.goToSeguimiento()
context.goToPropuestas()
context.goToChats()
context.goToCobranza()
context.goToSettings()
context.goToChangePassword()
```

### Detalle — apilan sobre el stack actual

```dart
context.goToNotifications()
context.goToDetalleChat(idLead: 123)
context.goToEditarLead(lead: lead, cubit: cubit)

// Con valor de retorno
final template = await context.goToTemplates(lead: lead)   // Template?
final assets   = await context.goToMediaPicker()           // List<AssetEntity>?
```

### Caso especial — desde Home a un chat

Construye el stack correcto para que el botón Back vuelva a ChatList:

```dart
context.goToDetalleChatDesdeHome(idLead: 123)
// Resultado: Home se limpia → ChatList queda como base → ChatDetail encima
```

### Navegación genérica

```dart
context.goBack()              // pop si puede
context.goBack(resultado)     // pop con valor de retorno
context.canGoBack()           // bool
context.clearAndPush('/ruta', arguments: {}) // push limpiando stack
```

### Diálogos

```dart
// Diálogo de confirmación con logo GS1
final confirmado = await context.showConfirmDialog(
  title: 'Confirmar',
  message: '¿Estás seguro?',
  confirmText: 'Sí',    // default: 'Confirmar'
  cancelText: 'No',     // default: 'Cancelar'
);
// retorna bool

// Logout con confirmación
context.logoutWithConfirmation(context);
// dispara AuthLogoutRequested si el usuario confirma
```

---

## NavigationService — sin BuildContext

Para navegar desde servicios, BLoCs o cualquier lugar sin contexto:

```dart
NavigationService.navigatorKey           // GlobalKey<NavigatorState>
NavigationService.currentContext         // BuildContext? actual
NavigationService.navigateTo('/ruta', arguments: {})
NavigationService.goBack()
NavigationService.goBack(resultado)
```

---

## Agregar una ruta nueva — pasos obligatorios

### 1. Constante en `app_routes.dart`

```dart
static const String miNuevaRuta = '/modulo/mi-ruta';
```

### 2. Registro en `app_router.dart` → `_registry`

```dart
AppRoutes.miNuevaRuta: RouteDefinition(
  transition: TransitionType.slideRight,
  builder: (context) {
    final args = _requireArgs<Map<String, dynamic>>(context);
    return MiNuevaPage(param: args['param'] as String);
  },
),
```

### 3. Extension en `navigation_extensions.dart`

```dart
Future<void> goToMiNuevaRuta({required String param}) =>
    _push(AppRoutes.miNuevaRuta, arguments: {'param': param});
```

Si la ruta retorna un valor, tipar el genérico:

```dart
Future<MiTipo?> goToMiNuevaRuta({required InfoLead lead}) =>
    _push<MiTipo>(AppRoutes.miNuevaRuta, arguments: {'lead': lead});
```

---

## Pasar un Cubit ya creado a una ruta

Cuando la Page destino necesita un Cubit que ya existe en el stack:

```dart
// En el router — envolver con BlocProvider.value
AppRoutes.detalleEditarLead: RouteDefinition(
  builder: (context) {
    final args = _requireArgs<Map<String, dynamic>>(context);
    return BlocProvider.value(
      value: args['cubit'] as MiCubit,
      child: MiPage(lead: args['lead'] as InfoLead),
    );
  },
),

// En la extension — pasar el cubit como argumento
Future<void> goToMiPage({
  required InfoLead lead,
  required MiCubit cubit,
}) => _push(AppRoutes.miRuta, arguments: {'lead': lead, 'cubit': cubit});

// Uso desde el widget
context.goToMiPage(lead: lead, cubit: context.read<MiCubit>());
```