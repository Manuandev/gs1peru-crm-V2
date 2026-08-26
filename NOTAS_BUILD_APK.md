# Notas — generar APK sin "error de paquetes"

Esto documenta por qué el APK sale bien en la PC personal pero falla (con
"error de paquetes" / conflicto al instalar) en la PC del trabajo, y qué
revisar en cada máquina antes de compilar.

## Causa raíz

`android/key.properties` y `android/upload-keystore.jks` **nunca se suben a
git** (están en `.gitignore`, correcto porque tienen las contraseñas del
keystore). Solo existen físicamente en la PC personal.

Mirar [android/app/build.gradle.kts](android/app/build.gradle.kts) líneas 16-92:
si el build de release no encuentra `key.properties`, cae automáticamente a
la firma **debug** en vez de tronar (y lo avisa con un banner grande en la
consola). El problema es que el keystore debug es distinto en cada máquina
(se autogenera solo). Entonces:

- APK compilado en la **PC personal** → firmado con `upload-keystore.jks` (el real).
- APK compilado en la **PC del trabajo** (sin esos 2 archivos) → firmado con
  el debug de esa PC, que no es el mismo que el de la PC personal.
- Si instalas el APK del trabajo sobre un celular que ya tenía una versión
  firmada distinta (la real, o el debug de otra PC) → Android rechaza la
  instalación: *"La app no se instaló porque el paquete entra en conflicto
  con un paquete existente"* (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). Ese es
  el "error de paquetes".

## Solución real — hacer esto antes de compilar en el trabajo

Copiar (por USB o algún medio privado, **nunca por git ni por chat** porque
llevan contraseñas) estos 2 archivos de esta PC a la del trabajo, en la
misma ruta `android/`:

- `android/key.properties`
- `android/upload-keystore.jks`

Si están bien copiados, al compilar release en el trabajo **ya no debe
aparecer** el banner de advertencia ("ADVERTENCIA: no se encontro
android/key.properties").

## Si de todos modos sale el conflicto al instalar

- Confirmar que ambos archivos existen en `android/` en la PC del trabajo y
  que `storeFile=../upload-keystore.jks` (dentro de `key.properties`) apunta
  bien relativo a esa carpeta.
- Como último recurso (se pierden datos locales de esa instalación de
  prueba): `adb uninstall com.gs1peru.crm` antes de instalar el nuevo APK.

## Versiones de referencia — PC personal, build funcionando (2026-08-26)

- Flutter 3.47.1 (stable)
- Dart 3.13.1
- Java: Temurin 25.0.3 (OpenJDK)
- Gradle wrapper: 8.14
- Android Gradle Plugin (AGP): 8.13.0
- Kotlin: 2.2.20
- `pubspec.yaml` → `environment.sdk: ^3.10.7`
- compileSdk/minSdk/targetSdk: los define Flutter (`flutter.compileSdkVersion`,
  etc.), no están hardcodeados en `build.gradle.kts`

Si en la PC del trabajo `flutter --version` da algo muy distinto a esto
(sobre todo Flutter/Dart), correr `flutter upgrade` ahí antes de compilar.

## Checklist rápido si aparece cualquier error de dependencias/paquetes

1. `flutter --version` → comparar con la lista de arriba.
2. `flutter clean`
3. `flutter pub get` — si falla por red, revisar que la red del trabajo no
   bloquee `pub.dev`, `dl.google.com` o `maven.google.com` (proxys
   corporativos a veces los cortan).
4. `flutter build apk --release --verbose` → leer el error real completo,
   no solo el resumen final.
5. "could not resolve dependency" / "could not download" → problema de red
   o proxy del trabajo, no del proyecto.
6. "duplicate class" / "namespace not specified" → no depende de la
   máquina; si aparece, es del código de la rama actual, no de esto.
