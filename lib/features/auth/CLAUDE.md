# Feature: Auth

Gestiona login, splash, logout y persistencia de sesión.

## Archivos clave

| Archivo | Qué hace |
|---|---|
| `data/datasources/remote/auth_remote_datasource.dart` | Login contra API |
| `data/datasources/local/auth_local_datasource.dart` | Lee/guarda/limpia sesión en SQLite |
| `data/models/session_model.dart` | Serializa/deserializa sesión |
| `domain/repositories/auth_repository.dart` | Interfaz |
| `data/repositories/auth_repository_impl.dart` | Implementación |
| `domain/usecases/logout_usecase.dart` | Caso de uso logout |
| `presentation/bloc/auth/auth_bloc.dart` | Árbitro global de sesión |
| `presentation/bloc/login/login_bloc.dart` | Flujo de login |
| `presentation/bloc/splash/splash_bloc.dart` | Verificación de sesión inicial |

---

## AuthBloc — global, vive en `app_widget.dart`

Es el único árbitro de sesión. Cualquier parte de la app puede leerlo.

```dart
// Leer estado
context.read<AuthBloc>().state

// Disparar logout
context.read<AuthBloc>().add(const AuthLogoutRequested());
```

**Estados:**
```dart
AuthInitial         // antes de verificar sesión
AuthAuthenticated   // sesión válida → navega a Home
AuthUnauthenticated // sin sesión → navega a Login
AuthLoading         // verificando/procesando
AuthError(message)  // error en login
```

**Listener global en `app_widget.dart`:**
```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) =>
      previous.runtimeType != current.runtimeType &&
      (current is AuthAuthenticated || current is AuthUnauthenticated),
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      context.read<DrawerBloc>().add(DrawerStarted());
      context.goToHome();
      context.read<CatalogsBloc>().add(const CatalogsLoadRequested());
    } else if (state is AuthUnauthenticated) {
      context.goToLogin();
    }
  },
)
```

---

## AuthLocalDatasource — SQLite

Tabla `session` — solo 1 registro activo a la vez.

```dart
final _local = AuthLocalDatasource();

await _local.getStoredSession()  // SessionModel? — null si no hay sesión
await _local.saveSession(session) // limpia primero, luego inserta
await _local.clearSession()       // logout — limpia tabla
```

**Flujo de sesión:**
```
App inicia
  └── getStoredSession()
        ├── null → AuthUnauthenticated → Login
        └── SessionModel → verificar expiración → AuthAuthenticated → Home
```

---

## LogoutUsecase

```dart
class LogoutUsecase {
  final AuthRepository _repository;
  const LogoutUsecase(this._repository);

  Future<void> call() async => await _repository.logout();
}

// Uso en AuthBloc:
await _logoutUsecase();
```

---

## SessionService — singleton

Acceso rápido a datos de sesión desde cualquier datasource:

```dart
final _session = SessionService();

_session.user         // User? — usuario autenticado
_session.codUser      // String — código de usuario
_session.userApe      // String — apellido del usuario
_session.isModerador  // bool — tiene permisos de moderador
_session.token        // String — token de API
```

---

## Flujo de autenticación completo

```
SplashPage
  └── SplashBloc verifica sesión local
        ├── Sin sesión → AuthUnauthenticated → LoginPage
        └── Con sesión → AuthAuthenticated → HomePage

LoginPage
  └── LoginBloc llama AuthRemoteDatasource
        ├── Error → muestra mensaje
        └── OK → guarda SessionModel en SQLite
                → AuthAuthenticated → HomePage (via AuthBloc listener)

Logout (desde cualquier pantalla)
  └── context.logoutWithConfirmation(context)
        └── AuthLogoutRequested
              → limpiarTokenFCM() + SignalR.close()
              → LocalNotificationService.cancelAll()  (ver notifications/CLAUDE.md)
              → clearSession() → AuthUnauthenticated → LoginPage
```

---

## Páginas

| Página | Ruta | Transición |
|---|---|---|
| `SplashPage` | `AppRoutes.splash` | fade |
| `LoginPage` | `AppRoutes.login` | fade |
| `RecuperarClavePage` | `AppRoutes.recuperarClave` | slideRight |
| `ChangePasswordPage` | `AppRoutes.changePassword` | material |

---

## RecuperarClaveCubit — `presentation/bloc/recuperar_clave/`

Gestiona el flujo de recuperación de clave por correo electrónico.

**Estados:**
```dart
RecuperarClaveInitial   // estado inicial
RecuperarClaveCargando  // llamada en curso
RecuperarClaveExito     // correo enviado correctamente
RecuperarClaveError(mensaje) // error de validación o de red
```

**Método principal:**
```dart
cubit.enviarCorreo(correo) // valida formato y llama al usecase
```

**UseCase:** `RecuperarClaveUseCase` → `AuthRepository.recuperarClave(correo)`

**Datasource:** `AuthRemoteDatasource.recuperarClave()` — contiene `TODO(backend)` con la implementación simulada hasta que el equipo defina el endpoint.

---

## AuthOlaClipper — `presentation/widgets/login/login_ola_clipper.dart`

Clipper genérico (renombrado desde `LoginOlaClipper`) reutilizado en:
- `LoginView` (`_ZonaAzul`)
- `RecuperarClaveView` (`_ZonaAzulRecuperar`)

---

## Actualización obligatoria de la app (agregado 2026-08-03)

Pedido de negocio: si el APK instalado quedó atrás de la última versión publicada, la app debe
bloquear tanto el login como cualquier guardado hasta que el usuario actualice — nunca dejar
pasar una escritura al backend con una versión vieja.

### Flujo

```
SplashBloc (una sola vez por arranque, en paralelo a la config)
  └── AppUpdateService().verificar()
        ├── GET ApiConstants.urlVersionCheck (host de archivos, natcodee.net — no es el
        │     backend del CRM, por eso usa un Dio propio en vez de ApiClient)
        ├── compara VersionUtils.esMenor(AppConstants.version, remota.Version)
        └── si hay pendiente → guarda en memoria + SQLite (setting 'update_pendiente')
              si NO hay pendiente → limpia cualquier flag viejo (el usuario ya actualizó)

LoginView.initState()
  └── si AppUpdateService().actualizacionPendiente != null
        → mostrarDialogoActualizacionObligatoria(context, info)  (diálogo genérico)

LoginView._handleLogin() / _handleGoogleLogin()
  └── vuelve a chequear (AppUpdateService().obtenerPendiente() — NO golpea la URL de
        nuevo, lee memoria o el respaldo en SQLite) ANTES de disparar LoginSubmitted
        → si hay pendiente, corta el login y muestra el mismo diálogo con mensaje propio
          ("No es posible iniciar sesión...")

Cualquier guardado en TODA la app (Leads/Contactos/Solicitudes/Cobranza/Propuestas/
Prospectos/Plantillas/Home — cualquier endpoint "...Cud...")
  └── UpdateRequiredInterceptor (core/network/interceptors/) — primer interceptor de
        ApiClient, antes de TokenBodyInterceptor
        → si hay pendiente, rechaza el request ANTES de mandarlo (nunca llega al
          backend) con un AppException — cae en el mismo ApiError/CrudError que cada
          pantalla ya maneja con su propio AppSnackBar.error(...), sin tocar ningún
          botón "Guardar" individual
```

**No cubre** envío de mensajes de WhatsApp ni subida de multimedia (`chat/`) — esos van por
SignalR o por endpoints que no siguen la convención de nombre "...Cud..." (`SendMessageWhatsApp`,
`GuardarMultimediaWhatsApp`), fuera de este bloqueo a propósito (pedido explícito: solo
"guardar" tipo formulario/CRUD).

### Piezas

| Archivo | Qué hace |
|---|---|
| `core/models/update_info.dart` | Modelo del JSON de `ApiConstants.urlVersionCheck` (`Version`/`DownloadUrl`/`ReleaseDate`) |
| `core/utils/version_utils.dart` | `VersionUtils.esMenor(actual, remota)` — compara "X.Y.Z" |
| `core/services/app_update_service.dart` | Singleton — `verificar()` (red, una vez por arranque), `obtenerPendiente()` (memoria → SQLite, sin red) |
| `core/network/interceptors/update_required_interceptor.dart` | Corta cualquier request a un endpoint "...Cud..." si hay actualización pendiente |
| `auth/presentation/widgets/login/update_required_dialog.dart` | Diálogo obligatorio (sin cerrar/back) — descarga con barra de progreso + `OpenFilex.open` para instalar. `titulo`/`mensaje` opcionales para variantes (ej. Login) |

**`AppConstants.version`** es la fuente de verdad de la versión instalada (ya en `'1.0.4'`,
mismo valor que se muestra en el footer de Login) — subirla en cada release junto con
`pubspec.yaml`.

**Instalación del APK** requiere `android.permission.REQUEST_INSTALL_PACKAGES`
(`AndroidManifest.xml`) + que el usuario habilite "Instalar apps desconocidas" para esta app en
Ajustes (permiso especial, no se puede conceder con un diálogo in-app — `permission_handler`
solo abre la pantalla de Ajustes; si no lo concede, el diálogo se queda en el mismo estado
mostrando "Reintentar").

**Si se agrega un endpoint CUD nuevo**, con que su ruta contenga "Cud" (como ya hace toda la
convención `ApiConstants` — `SPXxxCUDApp`) queda cubierto automáticamente por
`UpdateRequiredInterceptor`, sin tocar nada más.