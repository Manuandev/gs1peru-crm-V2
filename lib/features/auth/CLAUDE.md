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
              → LogoutUsecase → AuthRepositoryImpl.logout()
                    → AuthRemoteDatasource.logout()  (SP real, ver abajo — antes de
                      limpiar memoria/token, los necesita para armar el body)
                    → limpia memoria (SessionService/ApiClient) + SQLite
              → AuthUnauthenticated → LoginPage
```

### Logout — SP real (agregado 2026-08-07)

`AuthRemoteDatasource.logout()` llama `ApiConstants.urlLogout`
(`Seguridad/CerrarSesionAppCRM` → `dbo.CSV_SYSMUSER01_LOGOUT_APP`, task `'O'`) — el SP cierra
la sesión **por el TOKEN puntual de esta llamada** (`@L_TOKEN`, lo prepende
`TokenBodyInterceptor` del lado de Flutter) en `DBO.TOKEN` y en `DBO.TOKEN_GOOGLE` (prueba las
dos, la que no matchea no afecta filas) y limpia el token FCM en `SYSMUSER01_FCM`. Si no hay
`@L_TOKEN` (cierres forzados sin sesión restaurada a memoria, ver "Invalidar el TOKEN..." más
abajo) cierra lo que siga activo para ese `COD_USER` **en el mismo `NAVEGADOR`** (Android/iOS) —
nunca toca una sesión de otra plataforma (ej. la versión web) de la misma cuenta, ver "Un
celular por usuario, pero App y Web no se pisan" más abajo.

```dart
// Body (antes del token¯ que prepende TokenBodyInterceptor, que es el que
// identifica la sesión con prioridad — ver @L_TOKEN arriba):
// TIPO_USER¦NAVEGADOR¦ID_USUARIO¦IP_USUARIO¦LL_USUARIO¯O
final body = '${[
  'PER',                    // TIPO_USER — hardcodeado, igual que buildLoginBody(), sin uso en el SP
  info['navegador'],        // NAVEGADOR — usado en el fallback sin @L_TOKEN, ver abajo
  _session.codUser,         // ID_USUARIO — SessionService().codUser
  info['ip_local'],         // IP_USUARIO — sin uso en el SP
  info['coordenadas'],      // LL_USUARIO — sin uso en el SP
].join(camp)}${sep}O';
```

**Best effort** — `postSafe` nunca lanza excepción (atrapa `DioException` internamente), así
que si falla (sin internet, servidor caído) el logout local sigue adelante igual;
`AuthRepositoryImpl.logout()` llama `_remote.logout()` **antes** de limpiar
`ApiClient`/`SessionService`/SQLite, porque el body necesita el token y el `codUser` todavía
activos.

**Bug real corregido (2026-08-26) — el logout nunca cerraba la sesión Google en el backend.**
El SP solo hacía `UPDATE DBO.TOKEN ... WHERE TIPO_USER=@TIPO_USER AND COD_USER=@ID_USUARIO AND
NAVEGADOR=@NAVEGADOR` — `DBO.TOKEN` es la tabla de sesiones por credenciales; las sesiones
Google viven en `DBO.TOKEN_GOOGLE` (sin `COD_USER`, solo `CORREO`), así que ese `UPDATE`
siempre afectaba 0 filas para un usuario Google. Efecto real: presionar "Cerrar sesión" (o
cualquiera de los cierres forzados de `tryRestoreSession()`) limpiaba la sesión local sin
excepción, pero el `TOKEN_GOOGLE.TOKEN_ACT` de ese usuario se quedaba en `1` para siempre en el
backend — la validación de "sesión ya en curso" de `CSV_SYSMUSER01_LOGIN_GOOGLE_APP` nunca
podía disparar el caso `TOKEN_ACT = 0` en la práctica, y
`_cerrarSesionGoogleAnteriorSiCambiaDeCuenta()` (cambio de cuenta Google en el mismo
dispositivo) no cerraba nada de verdad.

**Segundo bug real, encontrado al revisar el primero — cerrar por `TIPO_USER+COD_USER+
NAVEGADOR` no distinguía app de web.** El negocio confirmó (2026-08-26): un usuario entra desde
**un solo celular a la vez** (no hay escenario real de 2 Androids simultáneos con la misma
cuenta) — pero **sí** puede tener sesión abierta en la app Y en la versión web al mismo tiempo,
con la misma cuenta (credenciales o Google), y cerrar sesión en una **no debe** cerrar la otra.
`NAVEGADOR` es justamente lo que distingue esto (`'Android'`/`'iOS'` desde la app —
`info['so']`, ver `buildLoginBody()` — vs. lo que mande la web, ej. el navegador real). El bug
real no era que `NAVEGADOR` se usara como clave — es la clave correcta para separar
plataformas — sino que el logout la ignoraba por completo y cerraba por `TIPO_USER+COD_USER+
NAVEGADOR` de forma mal aplicada (ver bug de arriba: nunca llegaba a tocar `TOKEN_GOOGLE`).
Corregido cerrando por **TOKEN exacto** cuando está disponible (más preciso que `NAVEGADOR`,
identifica una fila sin ambigüedad) y por `COD_USER + NAVEGADOR` en el fallback sin token — ver
"Un celular por usuario, pero App y Web no se pisan" más abajo.

No hizo falta ningún cambio en Flutter para ninguno de los dos — `AuthRemoteDatasource.logout()`
ya mandaba el token activo (vía `TokenBodyInterceptor`), `codUser` y `NAVEGADOR` en el body, el
SP simplemente no los aprovechaba bien.

### Auditoría de `CSV_SYSMUSER01_LOGOUT_APP` (agregado 2026-08-26)

**Hallazgo revisado y descartado — `CRM.SYSMUSER01_FCM` guarda un solo token por
`COD_USUARIO`, no uno por dispositivo.** Esto había quedado marcado como riesgo bajo el
supuesto de que un usuario podía tener 2+ celulares con sesión activa simultánea — el negocio
confirmó (2026-08-26) que eso no pasa (un usuario, un celular a la vez para la app). El push
FCM es exclusivo del celular (la web no registra token FCM), así que `UPDATE CRM.SYSMUSER01_FCM
... WHERE COD_USUARIO = @ID_USUARIO` sin filtrar por `NAVEGADOR` sigue siendo correcto —
cerrar sesión en el único celular de ese usuario debe limpiar su único token de push, sin
importar la plataforma. Sin acción pendiente acá.

**Optimización — 3 de los 5 campos que se parseaban del body no se usaban para nada.**
`@TIPO_USER` (siempre `'PER'`, ninguna rama lo compara) y `@IP_USUARIO`/`@LL_USUARIO` (nunca se
usaron en ninguna versión de este SP, no se escriben a ningún lado) se eliminaron. `@NAVEGADOR`
sí se conserva y se usa — es lo que evita que el fallback sin `@L_TOKEN` cierre por error una
sesión de otra plataforma (ver "Un celular por usuario, pero App y Web no se pisan" más abajo).
Flutter sigue mandando los 5 campos en el body (mismo formato, sin cambios ahí) — el SP
simplemente ya no declara ni lee los 3 que sobraban.

**Code smell corregido, luego reemplazado por el criterio final — `IF (@@ERROR>0)` en el
`CATCH` sin `BEGIN/END`.** Sin bloque explícito, el `IF` en T-SQL solo cubre la siguiente
instrucción — acá eso era `ROLLBACK`. Las líneas de abajo (`DECLARE`, el `SELECT` de
`ERROR_MESSAGE()`, `RAISERROR`) corrían **siempre**, sin importar el resultado del `IF`, pese a
que la indentación sugería que estaban adentro. No causaba ningún bug real porque dentro de un
bloque `CATCH`, `@@ERROR` es siempre distinto de 0 — pero es frágil. Primero se envolvió en
`BEGIN/END` explícito; en la pasada siguiente (ver abajo, "Segunda pasada") se reemplazó del
todo por `@@TRANCOUNT > 0` (mismo criterio que `LOGIN_APP`/`LOGIN_GOOGLE_APP`) — con esa
condición, dejar solo el `ROLLBACK` bajo el `IF` (sin `BEGIN/END`) ya es correcto y no
ambiguo: `SELECT`/`RAISERROR` deben correr siempre, con o sin rollback, así que el alcance
visible ahora sí coincide con el real.

**Menor, sin tocar** — no hay `ELSE` para `@L_TASK` distinto de `'O'`: si llegara cualquier otro
valor, el SP no devuelve nada (ni `'OK'` ni error), solo hace `COMMIT` de una transacción vacía.
Hoy es inalcanzable (`AuthRemoteDatasource.logout()` siempre manda `'O'`), pero si se agrega un
task nuevo sin agregar su propio `IF`, fallaría en silencio — vale la pena tenerlo en cuenta el
día que se agregue una tarea nueva a este SP.

### Un celular por usuario, pero App y Web no se pisan (decisión 2026-08-26)

**Regla de negocio confirmada:** un usuario entra desde **un solo celular a la vez** — no hay
escenario real de 2+ Androids simultáneos con la misma cuenta, así que no hace falta resolver
ese caso. **Pero** el mismo usuario puede tener, al mismo tiempo, sesión abierta en la **app** Y
en la **versión web** del CRM (misma cuenta, credenciales o Google) — y cerrar sesión en una de
las dos **nunca** debe cerrar la otra. `NAVEGADOR` (`'Android'`/`'iOS'` desde la app vs. lo que
mande la web) es la clave que separa ambas plataformas — el problema nunca fue usarla, fue que
el logout la ignoraba (ver bugs de arriba) y que Google nunca la aplicó ni siquiera en el login.

**Cambios en los 3 SP** — todos con el mismo criterio: limpiar sesiones viejas **del mismo
`NAVEGADOR`** (autolimpieza de tokens huérfanos — reinstalación, sesión perdida sin logout
explícito — dado que solo debería haber una fila activa por plataforma), sin tocar nunca la
plataforma contraria:

- `CSV_SYSMUSER01_LOGIN_APP` (rama de login fresco) — **recuperó** el
  `UPDATE DBO.TOKEN SET TOKEN_ACT = 0 WHERE TIPO_USER=@TIPO_USER AND COD_USER=@COD_USER AND
  NAVEGADOR=@NAVEGADOR` antes del `INSERT` (este SP ya lo tenía originalmente — nunca fue el
  problema real, solo se había quitado por error en una pasada anterior de esta misma revisión).
- `CSV_SYSMUSER01_LOGIN_GOOGLE_APP` (rama sin `@L_TOKEN`) — **ganó por primera vez** el mismo
  criterio: `UPDATE dbo.TOKEN_GOOGLE SET TOKEN_ACT = 0 WHERE CORREO=@CORREO AND
  NAVEGADOR=@NAVEGADOR` antes del `INSERT`. Este SP **nunca** tuvo este filtro — el original
  cerraba `WHERE CORREO = @CORREO` sin más, así que un login Google desde la app ya cerraba
  cualquier sesión Google de la web (y viceversa) desde antes de que se tocara nada en esta
  revisión. Es una corrección real, no un revert.
- `CSV_SYSMUSER01_LOGOUT_APP` — cierra por `TOKEN` puntual cuando está disponible (`@L_TOKEN` —
  más preciso que `NAVEGADOR`, identifica una fila exacta sin ambigüedad) y, en el fallback sin
  token, por `COD_USER + NAVEGADOR` — nunca por `COD_USER` solo, para no arriesgarse a cerrar la
  sesión web en un cierre forzado desde el Splash.

**Consecuencia esperada y aceptada** — `_cerrarSesionGoogleAnteriorSiCambiaDeCuenta()` (cambio
de cuenta Google en el mismo dispositivo, ver arriba) llama `logout(codUser: ...)` de la cuenta
vieja; si en ese momento no hay token de esa cuenta en memoria, cae en el fallback del logout —
que ahora cierra por `COD_USER + NAVEGADOR` (el `NAVEGADOR` de **este** dispositivo, que es
igual al que tenía la sesión vieja porque es el mismo equipo cambiando de cuenta), así que sigue
sin tocar una eventual sesión web de la cuenta vieja. Correcto sin necesitar ajuste extra.

### Auditoría de `CSV_SYSMUSER01_LOGIN_APP` (agregado 2026-08-26)

Revisión completa del SP de login por credenciales, buscando la misma clase de inconsistencias
encontradas en Google/Logout. Corregido en el SP (mismos 3 hallazgos, bajo riesgo — mismo
patrón ya validado en `CSV_SYSMUSER01_LOGIN_GOOGLE_APP`):

1. **La rama `IF(@L_TOKEN != '')` (resumir sesión con un token ya emitido) nunca completaba
   `@USER_APE`/`@CORREO_USER`/`@TELEFONO`/`@CELULAR`** — el `SELECT` de esa rama solo traía
   `TOKEN_ACT`/`COD_USER`/`ID_TIPOUSER`, así que la respuesta final volvía con esos 4 campos
   vacíos. Ahora el mismo `SELECT` trae también esos campos (mismo JOIN, sin costo extra).
2. **Esa misma rama no actualizaba `FCH_ULTIMA_INTERACCION`** al resumir — inconsistente con
   lo agregado a Google (que sí la marca en cada entrada, resumida o fresca). Se agregó el
   mismo `UPDATE DBO.TOKEN SET FCH_ULTIMA_INTERACCION = @FCH_SISTEMA WHERE TOKEN = @L_TOKEN`.
3. **Mensaje `'Session fue cerrada anteriormente.'`** (inglés a medias, sin tilde) → cambiado a
   `'Sesión fue cerrada anteriormente.'`, igual al texto que ya usa Google para el mismo caso.

**Nota** — como ya se documentó en "Re-login de Google..." arriba, esta rama de resumir sesión
por token no la dispara el flujo actual de Flutter (`tryRestoreSession()` para credenciales
siempre llama `login(username, password)` completo, nunca reenvía un token guardado) — los 3
fixes de arriba corrigen algo que hoy es código muerto en la práctica, pero queda correcto por
si se llega a usar (o si algún otro cliente además de esta app pega contra el mismo endpoint).

**Optimización (2026-08-26) — `ERROR_INACTIVO` aparecía 2 veces porque el cálculo de
`IB_MOD_APP` y el `SELECT` final de retorno estaban copiados tal cual en ambas ramas.** El
chequeo de `FLG_ESTADO = 0` en sí **sigue apareciendo 2 veces a propósito** — no es duplicación
evitable: la rama `IF` resuelve al usuario buscando por `TOKEN`, la rama `ELSE` lo resuelve
buscando por `USUARIO+CLAVE`, son dos consultas distintas que no se pueden fusionar en una sola,
y en la rama `ELSE` el chequeo tiene que ir **antes** del `INSERT` (si no, se volvía a crear un
TOKEN para un usuario desactivado, el bug original que motivó todo esto). Lo que sí era
duplicación innecesaria — el cálculo de `IB_MOD_APP` y el `SELECT ISNULL(STUFF(...))` final,
idénticos carácter por carácter en las dos ramas salvo qué variable de token usan — se movió a
un solo bloque común después del `IF/ELSE`, usando una variable `@TOKEN` unificada (antes solo
existía dentro de la rama `ELSE`; la rama `IF` usaba `@L_TOKEN` directo). Cada rama ahora solo
resuelve su propia validación y `SET @TOKEN = ...` (`@L_TOKEN` en la rama de resumen, `NEWID()`
en la de login fresco) antes de caer al bloque común.

**Hallazgo ya resuelto en pasadas posteriores de esta misma revisión (ver sección de arriba):**
el swap de columnas `REGION`/`CIUDAD` del `INSERT INTO DBO.TOKEN` se confirmó con el usuario
(compartió el esquema real de `DBO.TOKEN`: orden real `PAIS, REGION, CIUDAD`) y se corrigió
pasando el `INSERT` a lista de columnas explícita. El uso de `NAVEGADOR` como clave de "una
sesión activa a la vez" **no era el problema** — confirmado como el criterio correcto para
separar app de web, ver "Un celular por usuario, pero App y Web no se pisan" más arriba.

### Segunda pasada — transacciones + últimos detalles (agregado 2026-08-26)

Con `LOGIN_APP`/`LOGIN_GOOGLE_APP` haciendo cada vez más pasos (validar activo, cerrar sesión
previa, insertar), se revisaron de nuevo contra `LOGOUT_APP`:

- **`AND TOKEN_ACT = 1` agregado al `UPDATE` de "cerrar sesión previa"** en los dos SP (antes
  cerraba por `TIPO_USER+COD_USER+NAVEGADOR`/`CORREO+NAVEGADOR` sin filtrar por estado —
  reescribía `TOKEN_ACT = 0` incluso sobre filas ya inactivas de logins viejos, trabajo de más
  sin ningún efecto). Optimización menor, sin cambio de comportamiento.
- **Transacciones agregadas — confirmado con el usuario.** Ninguno de los dos SP envolvía sus
  escrituras (`UPDATE` de cierre previo + `INSERT`, o el `UPDATE` de resumen de sesión) en una
  transacción, a diferencia de `LOGOUT_APP` (`BEGIN TRY`/`BEGIN TRANSACTION`/`COMMIT` +
  `BEGIN CATCH`/`ROLLBACK`). Riesgo real aunque poco probable: si el `INSERT` fallara justo
  después de cerrar la sesión previa (timeout, disco lleno), el usuario quedaba sin ninguna
  sesión activa ahí. Se envolvió cada bloque de escritura (nunca los `SELECT`/validaciones con
  `RETURN` tempranas — esas van SIEMPRE antes de cualquier `BEGIN TRANSACTION`, para no dejar
  una transacción abierta colgando en un `RETURN` de "Token invalido"/"Usuario no existe"/etc.):
  ```sql
  BEGIN TRY
      BEGIN TRANSACTION
      -- UPDATE cierre previo + INSERT (o el UPDATE de resumen en LOGIN_APP)
      COMMIT
  END TRY
  BEGIN CATCH
      IF (@@TRANCOUNT > 0) ROLLBACK
      SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
      RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
      RETURN;
  END CATCH
  ```
  `IF (@@TRANCOUNT > 0) ROLLBACK` por seguridad extra — no asume que la transacción sigue
  abierta al entrar al `CATCH` (`LOGOUT_APP` usaba `IF (@@ERROR>0) ROLLBACK`, más simple, hasta
  que se armonizó al mismo criterio — ver "Tercera pasada" más abajo). El `RETURN;` después de
  `RAISERROR` es necesario acá (a diferencia de `LOGOUT_APP`, que no lo tiene porque no hay
  código después del `CATCH`) porque después del `IF/ELSE` sigue código común (`IB_MOD_APP` +
  `RETORNAR`) que no debe ejecutarse si la escritura falló — sin ese `RETURN` el SP intentaría
  armar una
  respuesta de éxito con datos a medio escribir. **No se pudo probar contra una base real** —
  revisar en un ambiente de prueba antes de subir a producción.
- Ajuste de redacción menor en el comentario de "4.1" de `LOGIN_GOOGLE_APP` ("otros equipos" →
  "otra plataforma", más preciso dado que ya no hay escenario de 2 celulares simultáneos).

### Tercera pasada — `LOGOUT_APP` armonizado con el patrón nuevo (agregado 2026-08-26)

Con el patrón `@@TRANCOUNT > 0` ya establecido en los dos SP de login, se revisó `LOGOUT_APP`
una vez más contra ese mismo criterio — único cambio real: `IF (@@ERROR > 0)` → `IF
(@@TRANCOUNT > 0)` en su `CATCH`, mismo motivo (más defensivo, no asume que la transacción
sigue abierta). De paso, con el criterio ya usando `@@TRANCOUNT`, dejar el `ROLLBACK` solo bajo
el `IF` (sin `BEGIN/END`) pasó de ser el code smell corregido antes a ser **correcto y sin
ambigüedad** — el `SELECT`/`RAISERROR` que siguen deben correr siempre (haya habido rollback o
no), así que el alcance real (`IF` de una sola línea) ya coincide con el alcance visible.

El resto de `LOGOUT_APP` no necesitó cambios: no tiene ningún `RETURN` temprano antes de su
único `COMMIT` (a diferencia de los SP de login, que sí tienen varias validaciones con `RETURN`
antes de cualquier escritura), así que envolver el `BEGIN TRANSACTION` desde el inicio del
`BEGIN TRY` — antes incluso de parsear el body — sigue siendo seguro ahí: no hay forma de que
la transacción quede abierta colgando en un `RETURN` intermedio, porque no existe tal
`RETURN` en este SP.

**Hallazgo que sigue sin tocarse — es harina de otro costal:**

- 🔒 **Las contraseñas se comparan con `UPPER(US.PASSUSER) = UPPER(@USER_PSW)`** — la
  contraseña que manda el cliente y la guardada en `SYSMUSER01.PASSUSER` se comparan en
  mayúsculas. Esto solo tiene sentido si `PASSUSER` guarda la contraseña en texto plano (o algo
  reversible a texto plano) — un hash real (bcrypt/Argon2/SHA) no sobrevive un `UPPER()` de
  forma consistente. Si es así, las contraseñas no están hasheadas y además la comparación es
  insensible a mayúsculas/minúsculas (reduce la variedad real de contraseñas posibles). Esto es
  un hallazgo de seguridad bastante más grande que la consistencia de estos SPs de sesión —
  no se tocó porque migrar a hash real es un cambio de arquitectura aparte (afecta todo login
  existente, necesita su propia conversación/plan), no algo para mezclar en este review.
- `@FLG_EXTRANJERO`/`@FLG_INGRESO` y el bloque comentado de validación de país (líneas
  `--IF ((UPPER(@PAIS)...`) son código muerto, ya deshabilitado a propósito — no rompe nada,
  solo ruido.
- `SET NOCOUNT OFF` al final del SP sin ningún `SET NOCOUNT ON` al inicio no hace nada (ya está
  `OFF` por defecto) — residuo inofensivo, probablemente de una plantilla.

### Invalidar el TOKEN también en cierres forzados desde el Splash (agregado 2026-08-07)

El mismo SP de logout se dispara ahora en **todo** lugar donde antes solo se limpiaba SQLite
sin avisar al backend — si no, el `TOKEN_ACT` de esa fila se quedaba en `1` para siempre,
aunque la app local ya tratara al usuario como deslogueado:

- `SplashBloc._onCheckSessionRequested` → rama `AppUpdateService().actualizacionPendiente !=
  null` (actualización obligatoria pendiente).
- `AuthRepositoryImpl.tryRestoreSession()` → sesión vencida (`entity.isExpired`), sesión no
  recordada (`SessionNotRememberedException`), Google sin `idToken`/`email` guardado, y Google
  cuyo re-login falla con `AppException` (ver más abajo — típicamente el idToken venció).

**`SessionModel`/tabla `session` (SQLite) ganó la columna `cod_user`** (migración a versión 4
de `LocalDatabase`, `_onUpgrade`) — se persiste en **ambos** logins (`login()`/
`loginWithGoogle()`, campo `UserModel.codUser`, que el backend siempre devuelve sin importar el
tipo). Es lo que permite invalidar el TOKEN en estos cierres forzados: en la mayoría de estas
ramas (Splash con actualización pendiente, sesión vencida, sesión no recordada) la sesión
**nunca llegó a restaurarse a memoria** — `SessionService()`/`ApiClient().token` siguen
vacíos, así que `AuthRemoteDatasource.logout()` no puede usar su default
(`SessionService().codUser`). Por eso `logout()` acepta un `codUser` opcional — el caller lee
el valor persistido directo de la `SessionModel`/`SessionEntity` guardada.
`AuthRepositoryImpl._invalidarTokenRemoto(SessionEntity)` centraliza esto para los 4 casos
dentro de `tryRestoreSession()`; `SplashBloc` lo hace inline (no tiene `AuthRepository`
inyectado, solo usecases) leyendo `AuthLocalDatasource().getStoredSession()` antes de limpiar.

Todas estas llamadas son **fire-and-forget** (`unawaited`) y best effort — nunca bloquean ni
interrumpen el flujo de Splash/restauración, y `AuthRemoteDatasource.logout()` nunca lanza
excepción (atrapa `DioException` en `postSafe`). Sesiones guardadas **antes** de este cambio no
tienen `cod_user` en su fila (columna nueva, queda `NULL`) — para esas, la invalidación remota
se salta en silencio (`if (id.isEmpty) return`) hasta que el usuario vuelva a loguearse una vez.

### Cambio de cuenta Google en dispositivos con varias cuentas sincronizadas (agregado 2026-08-14)

**Bug real reportado por el usuario** — dispositivo con dos cuentas de Google sincronizadas
(ej. Manuel y Antonio). Manuel tenía sesión guardada; al reiniciar la app y terminar entrando
con Antonio (selector nativo, silencioso o con el botón "Iniciar con Google"), el login no
avanzaba — sin ningún mensaje de error, la app simplemente no dejaba continuar.

`AuthRepositoryImpl.loginWithGoogle()` ahora llama primero a
`_cerrarSesionGoogleAnteriorSiCambiaDeCuenta(correo)`: lee la `SessionModel` guardada en SQLite,
y si es de tipo Google y su `email` **difiere** del correo con el que se está entrando ahora,
invalida el TOKEN de esa cuenta vieja en el backend (`AuthRemoteDatasource.logout(codUser:
...)`) **antes** de llamar al login nuevo. A diferencia de `_invalidarTokenRemoto()` (usado en
`tryRestoreSession()`, fire-and-forget/`unawaited`), acá se **espera** la respuesta a propósito
— si no se esperara, el login de la cuenta nueva podría llegar al backend antes de que
terminara de procesarse la desconexión de la vieja. Cubre tanto el re-login silencioso
(`tryRestoreSession()` → `loginWithGoogle()`) como el botón explícito "Iniciar con Google" en
Login (`LoginBloc._onLoginWithGoogleSubmitted` → mismo método), ya que ambos caminos pasan por
el mismo `loginWithGoogle()`. Si `session.codUser` es `null` (sesión vieja de antes de la
migración a esa columna, ver más abajo), el `logout()` remoto se salta en silencio (mismo
comportamiento que `_invalidarTokenRemoto`).

Solo aplica a cambio de cuenta **Google → Google** (alcance confirmado con el usuario) — no
compara contra una sesión de credenciales (usuario/clave) al cambiar a Google ni viceversa, eso
no se ha reportado como problema.

**Bug real reportado por el usuario (2026-08-26) — el cambio de cuenta nunca llegaba a
ejecutar nada de lo de arriba.** Repro: dispositivo con sesión de Manuel guardada, el usuario
toca "Iniciar con Google" en Login y elige a Programador (distinto) desde el selector nativo —
la app muestra "Accediendo..." y vuelve al formulario **sin ningún snackbar de error**, sin
entrar a la app, y el `TOKEN_ACT` de Manuel se queda en `1` en el backend. Causa raíz:
`GoogleSignIn.instance.authenticate()` (`login_bloc.dart._onLoginWithGoogleSubmitted`) lanzaba
`GoogleSignInException(code: canceled)` — el SDK (Credential Manager por debajo, desde
`google_sign_in ^7.2.0`) choca con la sesión ligera ya cacheada de Manuel al intentar
autenticar una cuenta distinta, y reporta el intento completo como "cancelado" **aunque el
usuario sí haya elegido una cuenta**. El código ya trataba `canceled` como "el usuario cerró el
selector sin elegir nada" (`emit(const LoginInitial())`, sin snackbar, patrón intencional para
ese caso real) — pero acá disparaba con un falso positivo. Como la excepción explota dentro de
`authenticate()` mismo, **nunca se llega a `loginWithGoogle()`**, así que
`_cerrarSesionGoogleAnteriorSiCambiaDeCuenta()` (la función de arriba que cierra a Manuel) nunca
se ejecuta — de ahí el `TOKEN_ACT = 1` persistente.

Corregido agregando `await GoogleSignIn.instance.signOut()` justo antes de `authenticate()` en
`_onLoginWithGoogleSubmitted` — "olvida" la cuenta cacheada del SDK primero, así el selector
siempre hace una autenticación limpia en vez de chocar con un estado previo. Sin costo en el
primer login de un dispositivo (no hay nada que olvidar). No toca el flujo de restauración
silenciosa (`_reautenticarGoogleSilenciosamente()`/`attemptLightweightAuthentication()`, ver
arriba) — ese nunca abre el selector, no le aplica este problema.

### Re-login de Google en silencio — reusa el TOKEN del backend antes de tocar Google (agregado 2026-08-26)

`tryRestoreSession()` (rama `entity.isGoogle`) prueba dos estrategias en orden, cada una con su
propio fallback:

```
1. _intentarReusarTokenGoogle(entity)
     → reenvía entity.idToken (el TOKEN que el backend ya tiene activo en TOKEN_GOOGLE,
       NO el idToken crudo de Google) como @L_TOKEN — el SP lo valida y responde sin
       generar una fila nueva ni tocar el SDK de Google.
     → null si no había token guardado, o el backend lo rechazó (no encontrado /
       TOKEN_ACT = 0 por un cierre remoto)
2. (fallback) _reautenticarGoogleSilenciosamente(entity.email)
     → pide un idToken FRESCO a GoogleSignIn.instance.attemptLightweightAuthentication()
       (sin diálogo) y hace un loginWithGoogle() completo con él — mismo mecanismo que
       existía antes de este cambio (ver abajo)
     → null si tampoco hay nada que restaurar en silencio → invalida TOKEN remoto + Login
```

**`AuthRepositoryImpl._intentarReusarTokenGoogle(SessionEntity entity)`** — pone
`ApiClient().setToken(entity.idToken!)` (así `TokenBodyInterceptor` lo prepende como
`@L_TOKEN` en el body) y llama `loginWithGoogle(accessToken: entity.idToken!, correo:
entity.email!)`. El SP `CSV_SYSMUSER01_LOGIN_GOOGLE_APP` (`DBEAN`) tiene una rama `IF
(@L_TOKEN != '')` — busca ese TOKEN en `TOKEN_GOOGLE`: si no existe → `'ERROR¯Token
invalido.'`; si existe pero `TOKEN_ACT = 0` (cerrado por el SP de logout u otro dispositivo)
→ `'ERROR¯Sesión fue cerrada anteriormente.'`; si está activo, reutiliza ese mismo TOKEN sin
insertar una fila nueva. Cualquiera de los dos errores llega como `AppException` (mismo
mecanismo de parseo que cualquier otro `'ERROR¯...'` del backend, ver `UserModel.fromRawString`)
— `_intentarReusarTokenGoogle` lo atrapa, limpia el token en memoria
(`ApiClient().clearToken()`) y retorna `null` para que el caller caiga al fallback.

**Por qué `entity.idToken` ya NO es el idToken crudo de Google** — `loginWithGoogle()` ahora
guarda `idToken: user.token` (lo que el backend devolvió/confirmó como TOKEN activo), no el
`accessToken` que se le pasó como parámetro. Motivo: el SP declara la variable `@TOKEN` como
`VARCHAR(400)` — un idToken de Google (JWT largo, ~800-1200 caracteres) queda truncado al
guardarlo en `TOKEN_GOOGLE.TOKEN`, así que reenviar el JWT completo original nunca iba a
matchear con `WHERE TOKEN = @L_TOKEN`. Guardando el valor que el propio backend ya truncó y
devolvió, lo que se reenvía en el siguiente arranque es *exactamente* lo que quedó en la fila,
sin tener que conocer ni replicar esa lógica de truncado en Flutter.

⚠️ **Punto sin verificar** — `login_bloc.dart` tiene un comentario ("el backend valida con
Google tokeninfo usando este token") que sugiere que el controlador .NET (fuera de este repo,
no visible desde acá) podría validar el `accessToken` contra los servidores de Google en
*cada* llamada a este endpoint, no solo en el login inicial. Si es así, reenviar un token viejo
en el resumen de sesión podría seguir siendo rechazado por esa capa aunque el SP ya lo acepte —
en ese caso `_intentarReusarTokenGoogle` simplemente cae al fallback de siempre (ninguna
regresión), solo no logra el ahorro de no tocar el SDK de Google. Si se confirma que esa
validación es incondicional, conviene revisar el controlador para saltarla cuando `@L_TOKEN`
venga con un TOKEN_GOOGLE activo.

**`AuthRepositoryImpl._reautenticarGoogleSilenciosamente(String? emailGuardado)`** (fallback,
sin cambios desde 2026-08-07) — usa `GoogleSignIn.instance.attemptLightweightAuthentication()`
(`google_sign_in: ^7.2.0`, ya inicializado en `main()` con
`GoogleSignIn.instance.initialize(serverClientId: ...)` antes de `runApp()`) para pedir un
idToken **fresco** sin mostrar ningún diálogo — restaura la sesión nativa del SDK en el
dispositivo (misma cuenta con la que se hizo `authenticate()` la primera vez) siempre que el
usuario no haya cerrado sesión de Google ni revocado el acceso a nivel de sistema. Verifica que
el email de la cuenta recuperada coincida con `emailGuardado` antes de confiar en ella. Si
retorna `null` (sesión nativa también perdida/revocada), cae al flujo de siempre: invalida el
TOKEN remoto con `_invalidarTokenRemoto()` y manda a Login.

### `FCH_ULTIMA_INTERACCION` — cuándo volvió a entrar (agregado 2026-08-26)

El SP `CSV_SYSMUSER01_LOGIN_GOOGLE_APP` actualiza `TOKEN_GOOGLE.FCH_ULTIMA_INTERACCION =
GETDATE()` por `CORREO` en **cada** ejecución exitosa — tanto cuando crea un TOKEN nuevo (login
fresco) como cuando reutiliza uno existente (rama `@L_TOKEN != ''` de arriba). Sirve para saber
la última vez que ese usuario realmente reabrió la app, sin depender de que el token cambie.

### Usuario desactivado (`FLG_ESTADO = 0`) — mensaje propio, valida ANTES del token (agregado 2026-08-26)

**Bug real reportado por el usuario** — un asesor con la cuenta desactivada
(`SYSMUSER01_EXT.FLG_ESTADO = 0`) recibía el mismo mensaje genérico que alguien que nunca tuvo
cuenta ("Correo no asociado a ningún asesor" / "El usuario ingresado no existe"), sin ninguna
pista de que el problema era que estaba desactivado — confusión reportada por varios usuarios.
Además, en ambos SPs de login (`CSV_SYSMUSER01_LOGIN_APP` y `CSV_SYSMUSER01_LOGIN_GOOGLE_APP`,
`DBEAN`) el login fresco creaba/activaba el `TOKEN`/`TOKEN_GOOGLE` **antes** de confirmar que el
usuario existía y estaba activo.

Corregido en los dos SPs — la consulta a `SYSMUSER01`/`SYSMUSER01_EXT` ya NO filtra por
`FLG_ESTADO` en el `WHERE` (antes lo combinaba con la validación de existencia/credenciales, lo
que hacía indistinguibles ambos casos); ahora se trae `FLG_ESTADO` a una variable y se valida en
2 pasos, **siempre antes** de tocar la tabla de tokens (en ninguna rama, ni login fresco ni
resumen de sesión con token existente):

```sql
IF (@COD_USER IS NULL)                    -- no existe ningún usuario con ese correo/credenciales
BEGIN
    SELECT CONCAT('ERROR_CORREO', @sepListas, 'Correo no asociado a ningún asesor.');
    -- (LOGIN_APP usa 'ERROR¯El usuario ingresado no existe', mismo criterio)
    RETURN;
END

IF (@FLG_ESTADO = 0)                      -- existe, pero está desactivado
BEGIN
    SELECT CONCAT('ERROR_INACTIVO', @sepListas, 'Tu usuario está desactivado. Solicita a un administrador que lo active.');
    RETURN;
END
```

Ese mensaje llega tal cual a Flutter como `AppException` (mismo mecanismo de parseo que
cualquier `'ERROR¯...'` del backend — ver `UserModel.fromRawString`) y `LoginBloc` lo emite
directo con `LoginFailure(e.message)`, tanto en `_onLoginSubmitted` como en
`_onLoginWithGoogleSubmitted` — no hizo falta ningún cambio en Flutter, ya mostraba el mensaje
que mandara el backend.

**Ojo con el flujo de Splash (`tryRestoreSession()`)** — si la cuenta se desactiva DESPUÉS de
que el usuario ya tenía una sesión guardada, el intento de resumir (rama `@L_TOKEN != ''`, ver
arriba) también revisa `FLG_ESTADO` ahora y falla con este mismo mensaje — pero ese error se
atrapa en silencio ahí (mismo patrón que `TOKEN_ACT = 0`/token inválido, cae al fallback o
limpia sesión → Login) y **no se muestra en el Splash mismo**, recién se ve si el usuario
intenta loguearse de nuevo manualmente. Se dejó así a propósito, por consistencia con el resto
de cierres silenciosos de sesión en `tryRestoreSession()` (sesión vencida, no recordada,
Google revocado) — ninguno de esos muestra mensaje en el Splash tampoco.

**`IF(@L_TOKEN != '')` de `LOGIN_APP` (resumen de sesión con credenciales) ganó la misma
validación de `FLG_ESTADO`** que ya tenía Google — antes esa rama no chequeaba el estado en
absoluto, así que una cuenta desactivada podía seguir "resumiendo" sesión con un TOKEN viejo
mientras siguiera activo. Nota aparte, no corregida en esta sesión por no ser lo pedido: esa
misma rama nunca completó `@USER_APE`/`@CORREO_USER`/`@TELEFONO`/`@CELULAR` (siempre vienen
vacíos en la respuesta) — gap preexistente, independiente de este cambio.

---

## Método de login mostrado (grupo TLA)

`LoginView` decide qué mostrar (solo Google / solo credenciales / ambos) según
`ConfiguracionService().tipoLogin`, que sale del grupo `TLA` de `T_CONFIGURACION`
(cargado en `SplashBloc`, task `'CA'`).

**Default = solo Google** en los 3 puntos donde puede faltar el dato (pedido de
negocio, 2026-08-31 — la cuenta corporativa es el camino principal):

| Caso | Archivo | Fallback |
|---|---|---|
| Config nunca cargó (`_config == null` — backend sin respuesta) | `core/services/configuracion_service.dart` | `TipoLoginApp.google` |
| Config cargó pero TLA sin opción activa (`valor5 == '1'`) | `core/domain/entities/app_configuracion.dart` | `ConfiguracionKeys.idLoginGoogle` |
| Id de login desconocido | `core/models/configuracion_item.dart` (`TipoLoginApp.fromId`) | `TipoLoginApp.google` |

Antes de este cambio el fallback era `credenciales`/`ambos` — el riesgo asumido
es que si Google no está disponible en el dispositivo **y** el backend no
responde, ese usuario no tiene forma de entrar hasta que la config cargue bien.

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
SplashBloc (una sola vez por arranque, en paralelo a la config — solo en el escenario
"usuario recurrente", ver abajo)
  └── AppUpdateService().verificar()
        ├── GET ApiConstants.urlVersionCheck (host de archivos, natcodee.net — no es el
        │     backend del CRM, por eso usa un Dio propio en vez de ApiClient)
        ├── compara VersionUtils.esMenor(AppConstants.version, remota.Version)
        └── si hay pendiente → guarda en memoria + SQLite (setting 'update_pendiente')
              si NO hay pendiente → limpia cualquier flag viejo (el usuario ya actualizó)

  └── si AppUpdateService().actualizacionPendiente != null (recién resuelto arriba)
        → AuthLocalDatasource().clearSession() + emit(SplashSessionNotFound()) — NO
          llama _restoreSessionUsecase(), aunque hubiera una sesión guardada válida.
          Manda directo a Login sin restaurar nada.
        si NO hay pendiente → sigue el flujo normal (_restoreSessionUsecase())

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

**Bug real corregido (2026-08-07) — un usuario con sesión recordada entraba directo a Home
con una versión vieja, sin ver nunca el diálogo obligatorio.** Antes, `SplashBloc` siempre
llamaba `_restoreSessionUsecase()` sin mirar el resultado de `AppUpdateService().verificar()`
— con sesión válida, iba directo a `SplashSessionFound()` → Home. El único candado en ese
caso era `UpdateRequiredInterceptor`, que bloquea guardados pero deja navegar y leer
libremente — el asesor podía usar la app entera sin enterarse de que había una actualización
pendiente, hasta el primer intento de guardar. Corregido: `_onCheckSessionRequested` (rama
"usuario recurrente") ahora chequea `AppUpdateService().actualizacionPendiente` justo después
del `Future.wait` que corre `verificar()` — si hay pendiente, limpia la sesión guardada
(`AuthLocalDatasource().clearSession()`) y emite `SplashSessionNotFound()` directo, sin llamar
`_restoreSessionUsecase()` — el usuario cae en Login y ahí `LoginView.initState()` ya muestra
el diálogo obligatorio de inmediato (mismo mecanismo de siempre, ver arriba). No aplica al
escenario "primer ingreso" (`onboarding == null`) — ahí `verificar()` corre en background
(`unawaited`) y todavía no hay ninguna sesión que restaurar/limpiar.

**Bug real corregido (2026-08-07) — la subida de voucher/O.C. en Solicitudes (task `'AR'`,
`SolicitudRemoteDatasource.guardarArchivo()`) no atrapaba el rechazo del interceptor.** A
diferencia del resto de endpoints CUD (que usan `ApiClient.postSafe`, con su propio
try/catch), ese método usa `postMultipart`, que no captura `DioException` — el rechazo de
`UpdateRequiredInterceptor` se propagaba sin capturar hasta la vista, dejando el overlay de
guardado pegado en "cargando" en vez de mostrar el mensaje. Corregido: `guardarArchivo()`
ahora envuelve el loop de chunks en `try/catch (DioException)` y relanza como `AppException`;
`generarSolicitudCompleta()`/`guardarBorradorCompleto()` (`solicitud_guardar_helper.dart`,
`solicitudes/`) atrapan esa excepción alrededor de `subirArchivosPendientes()` y la convierten
en `CrudError(e.message)` — mismo patrón que el resto del flujo.

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

**`AppConstants.version`** es la fuente de verdad de la versión instalada (ya en `'1.0.5'`,
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