# Feature: Settings

Configuración de la app: tema claro/oscuro y preferencias de usuario.

## Archivos clave

| Archivo | Qué hace |
|---|---|
| `presentation/pages/settings_page.dart` | Pantalla de configuración |
| `core/theme/theme_cubit.dart` | Controla ThemeMode globalmente |

---

## ThemeCubit — global, vive en `app_widget.dart`

Controla el modo claro/oscuro de toda la app. Estado es `ThemeMode`.

```dart
// Leer modo actual
context.watch<ThemeCubit>().state  // ThemeMode

// Cambiar tema
context.read<ThemeCubit>().toggleTheme()  // alterna entre light y dark
context.read<ThemeCubit>().setTheme(ThemeMode.dark)
context.read<ThemeCubit>().setTheme(ThemeMode.light)
context.read<ThemeCubit>().setTheme(ThemeMode.system)
```

El `ThemeCubit` persiste la preferencia en `LocalDatabase` tabla `settings`:
```dart
await db.setSetting('theme', 'dark')   // guarda
await db.getSetting('theme')           // lee al iniciar
```

---

## Mostrar selector de tema en UI

```dart
// Usar AppIcons según el modo actual
BlocBuilder<ThemeCubit, ThemeMode>(
  builder: (context, themeMode) {
    final isDark = themeMode == ThemeMode.dark;
    return IconButton(
      icon: Icon(isDark ? AppIcons.lightMode : AppIcons.darkMode),
      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
    );
  },
)
```

---

## Logout desde Settings

```dart
context.logoutWithConfirmation(context);
// muestra showConfirmDialog con logo GS1
// si confirma → AuthLogoutRequested → clearSession() → LoginPage
```

---

## Cambiar contraseña

```dart
context.goToChangePassword()  // clearAndPush — limpia stack
```

---

## Ruta

| Página | Ruta | Transición |
|---|---|---|
| `SettingsPage` | `AppRoutes.settings` | material (desde Drawer) |