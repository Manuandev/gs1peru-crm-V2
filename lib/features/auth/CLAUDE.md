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
        └── AuthLogoutRequested → clearSession() → AuthUnauthenticated → LoginPage
```

---

## Páginas

| Página | Ruta | Transición |
|---|---|---|
| `SplashPage` | `AppRoutes.splash` | fade |
| `LoginPage` | `AppRoutes.login` | fade |
| `ChangePasswordPage` | `AppRoutes.changePassword` | material |