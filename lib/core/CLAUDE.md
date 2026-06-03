# Design System — lib/core

Todo el sistema de diseño vive aquí. Nunca usar literales en widgets.
Si un token no existe → crearlo en el archivo correspondiente con comentario → luego usarlo.

---

## Archivos y responsabilidades

| Archivo | Qué contiene |
|---|---|
| `constants/app_colors.dart` | Todos los colores de la app |
| `constants/app_spacing.dart` | Espaciado (xxs → xxxl) |
| `constants/app_sizing.dart` | Radios, elevaciones, iconos, botones, avatares |
| `constants/app_text_styles.dart` | Tipografía y escala de texto |
| `constants/app_icons.dart` | Íconos Material centralizados |
| `constants/app_icons_social.dart` | Íconos FontAwesome (canales + etapas CRM) |
| `constants/app_images.dart` | Paths de assets SVG/PNG |
| `constants/app_constants.dart` | Constantes globales (versión, separadores) |
| `constants/app_breakpoints.dart` | Breakpoints responsive |
| `theme/app_theme.dart` | lightTheme + darkTheme Material 3 |
| `utils/responsive_helper.dart` | Helpers + widgets responsive |
| `utils/color_utils.dart` | Colores dinámicos por nombre |
| `utils/date_formatter.dart` | Formateo de fechas |
| `utils/date_formats.dart` | Enum AppDateFormat |
| `utils/date_extensions.dart` | Extensions String/DateTime |
| `utils/elapsed_time_utils.dart` | Tiempo transcurrido con color de urgencia |
| `database/local_database.dart` | SQLite singleton (LocalDatabase) |
| `widgets/` | Widgets custom reutilizables |

---

## AppColors — `constants/app_colors.dart`

```dart
// Marca GS1
AppColors.primary        // #002C6C — azul corporativo
AppColors.secondary      // #F26334 — naranja corporativo

// Estado
AppColors.success        // #4CAF50
AppColors.error          // #F44336
AppColors.warning        // #FF9800
AppColors.info           // #2196F3

// Fondo
AppColors.background         // #F8F9FB (light scaffold)
AppColors.backgroundDark     // #121212 (dark scaffold)
AppColors.surface            // #FFFFFF
AppColors.surfaceLight       // #FFFFFF
AppColors.surfaceLightVariant // #F3F4F6
AppColors.surfaceDark        // #1E1E1E
AppColors.surfaceDarkVariant // #2A2A2A (inputs dark)

// Texto
AppColors.textPrimary    // #1A1A1A
AppColors.textSecondary  // #757575
AppColors.textDisabled   // #BDBDBD
AppColors.textOnDark     // #FFFFFF

// Bordes
AppColors.border         // #E0E0E0
AppColors.borderFocused  // = primary
AppColors.borderError    // = error

// Grises
AppColors.grey50 … AppColors.grey900

// Gradiente Login/Splash
AppColors.gradientStart  // #667eea
AppColors.gradientEnd    // #764ba2

// Inputs
AppColors.inputBackground
AppColors.inputBorder
AppColors.inputFocused
AppColors.inputHint
AppColors.inputText

// Otros
AppColors.divider
AppColors.cardShadow

// Helpers con opacidad
AppColors.black(0.5)              // rgba(0,0,0,0.5)
AppColors.white(0.8)              // rgba(255,255,255,0.8)
AppColors.primaryWithOpacity(0.1) // primary al 10%
```

**Snackbar "on" colors:** `AppColors.onSuccess` · `onError` · `onWarning` · `onInfo`

---

## AppSpacing — `constants/app_spacing.dart`

```dart
AppSpacing.xxs  // 2px  — separadores mínimos, badges
AppSpacing.xs   // 4px  — gap ícono-texto
AppSpacing.sm   // 8px  — padding interno botones
AppSpacing.md   // 16px — BASE, padding estándar
AppSpacing.lg   // 24px — separación entre secciones
AppSpacing.xl   // 32px — bloques principales
AppSpacing.xxl  // 48px — logo e inputs en Splash
AppSpacing.xxxl // 64px — espacios especiales

// Alias semánticos
AppSpacing.screenPadding          // 16px
AppSpacing.cardPadding            // 16px
AppSpacing.formSpacing            // 16px
AppSpacing.sectionSpacing         // 32px
AppSpacing.buttonPaddingHorizontal // 32px
AppSpacing.buttonPaddingVertical   // 16px
```

---

## AppSizing — `constants/app_sizing.dart`

```dart
// Border radius
AppSizing.radiusXs       // 4px  — chips, badges
AppSizing.radiusSm       // 8px  — snackbars, tooltips
AppSizing.radiusMd       // 12px — BASE: inputs, botones, cards
AppSizing.radiusLg       // 16px — cards principales, dialogs
AppSizing.radiusXl       // 24px — bottom sheets, cards hero
AppSizing.radiusCircular // 999px — avatares, FABs

// Elevación
AppSizing.elevationNone   // 0
AppSizing.elevationLow    // 2
AppSizing.elevationMedium // 4
AppSizing.elevationHigh   // 8

// Iconos
AppSizing.iconSm       // 16px — labels, chips
AppSizing.iconActionSm // 18px — botones de acción
AppSizing.iconMd       // 24px — BASE Material
AppSizing.iconNav      // 22px — drawer/nav items
AppSizing.iconLg       // 32px — headers, estados vacíos
AppSizing.iconXl       // 48px — pantallas error/éxito
AppSizing.iconXxl      // 80px — logo en login
AppSizing.iconDisplay  // 120px — logo en Splash

// Controles
AppSizing.buttonHeight      // 48px
AppSizing.buttonHeightSmall // 36px
AppSizing.buttonHeightLarge // 56px
AppSizing.inputHeight       // 56px
AppSizing.appBarHeight      // 56px

// Avatares
AppSizing.avatarSm // 42px  | AppSizing.avatarRadiusSm // 21px
AppSizing.avatarMd // 48px  | AppSizing.avatarRadiusMd // 24px
AppSizing.avatarLg // 56px  | AppSizing.avatarRadiusLg // 28px
AppSizing.avatarXl // 72px  | AppSizing.avatarRadiusXl // 36px

// Anchos máximos
AppSizing.maxWidthForm    // 400px — formularios login/registro
AppSizing.maxWidthContent // 600px — artículos, descripción
AppSizing.maxWidthWide    // 1200px — dashboards, tablas

// Spinners
AppSizing.spinnerStrokeSmall  // 2px
AppSizing.spinnerStrokeMedium // 3px
AppSizing.spinnerStrokeLarge  // 4px
```

---

## AppTextStyles — `constants/app_text_styles.dart`

Fuente principal: **Roboto** | Mono: **RobotoMono**

Los estilos base **NO llevan color** — el tema lo inyecta automáticamente.
Solo usar color explícito sobre gradientes (Splash/Login).

```dart
// Display
AppTextStyles.displayLarge   // 57px bold
AppTextStyles.displayMedium  // 48px bold

// Headline
AppTextStyles.headlineLarge  // 36px bold
AppTextStyles.headlineMedium // 28px bold
AppTextStyles.headlineSmall  // 22px bold

// Title
AppTextStyles.titleLarge     // 22px semiBold
AppTextStyles.titleMedium    // 16px semiBold
AppTextStyles.titleSmall     // 14px semiBold

// Body
AppTextStyles.bodyLarge      // 16px regular
AppTextStyles.bodyMedium     // 14px regular — BASE texto estándar
AppTextStyles.bodySmall      // 12px regular

// Label
AppTextStyles.labelLarge     // 14px medium
AppTextStyles.labelMedium    // 12px medium
AppTextStyles.labelSmall     // 11px medium — micro texto, badges

// Botones
AppTextStyles.button          // 16px bold
AppTextStyles.buttonSecondary // 16px medium
AppTextStyles.buttonSmall     // 14px medium

// Escala de tamaños (para .copyWith manual)
AppTextStyles.sizeXs  // 11px
AppTextStyles.sizeSm  // 12px
AppTextStyles.sizeMd  // 14px
AppTextStyles.sizeLg  // 16px
AppTextStyles.sizeXl  // 18px
AppTextStyles.size2xl // 22px
AppTextStyles.size3xl // 28px
AppTextStyles.size4xl // 36px
AppTextStyles.size5xl // 40px
AppTextStyles.size6xl // 48px
AppTextStyles.size7xl // 57px

// Pesos
AppTextStyles.weightRegular  // w400
AppTextStyles.weightMedium   // w500
AppTextStyles.weightSemiBold // w600
AppTextStyles.weightBold     // w700
```

---

## AppIcons — `constants/app_icons.dart`

Siempre `Icon(AppIcons.xxx)`. Nunca `Icons.xxx` directamente.

```dart
// Navegación
AppIcons.home / homeFilled / back / forward / menu / close / more / moreHorizontal

// Acciones
AppIcons.search / filter / sort / add / edit / delete / save / cancel / check / checkCircle

// Usuario / Auth
AppIcons.user / userFilled / users / login / logout
AppIcons.lock / lockOpen / visibility / visibilityOff

// Comunicación
AppIcons.email / phone / message / chat / notification / notificationFilled

// Archivos
AppIcons.file / fileOutlined / folder / upload / download / attach / image / pdf

// Configuración
AppIcons.settings / info / help / language / darkMode / lightMode

// Estado / Feedback
AppIcons.success / error / warning / infoCircle

// Fechas
AppIcons.calendar / time / date

// Ubicación
AppIcons.location / map / directions

// Comercio
AppIcons.cart / moneda / payment / creditCard / receipt

// Favoritos
AppIcons.favorite / favoriteFilled / star / starFilled / starHalf

// Otros
AppIcons.copy / share / print / refresh / sync

// Splash
AppIcons.lightning // rayo — logo splash
```

---

## AppIconsSocial — `constants/app_icons_social.dart`

Para canales de origen y etapas de lead. Siempre `FaIcon(AppIconsSocial.xxx)`.

```dart
// Helpers listos — usar siempre estos en lugar de construir manualmente
AppIconsSocial.widgetCanal(id, size: 14)    // FaIcon con color correcto del canal
AppIconsSocial.widgetEstado(id, size: 14)   // FaIcon con color de etapa
AppIconsSocial.chipEstado(id, label: '...')  // Chip con bg + color de etapa
AppIconsSocial.colorCanal(id)               // Color del canal
AppIconsSocial.colorEstado(id)              // Color del estado
AppIconsSocial.bgEstado(id)                 // Color de fondo del estado
```

**Canales (id int):**

| ID | Canal | Color |
|---|---|---|
| 1 | WhatsApp | #25D366 |
| 3 | TikTok | #010101 |
| 4 | Instagram | Gradiente |
| 5 | Facebook | #1877F2 |
| 6 | LinkedIn | #0A66C2 |
| 7 | Web GS1 | #607D8B |
| 8 | Instapage | Gradiente |
| 9 | Boca a Boca | #9C27B0 |
| 10 | Migración | #455A64 |
| 11 | Referido | #00897B |
| 12 | Manual | #6D4C41 |

**Etapas (id string):**

| ID | Etapa | ID | Etapa |
|---|---|---|---|
| "00" | Nuevo | "08" | Pendiente |
| "01" | En Desarrollo | "09" | Sin Respuesta |
| "02" | Propuesta | "10" | Desiste |
| "03" | Ficha | "11" | Ganado |
| "04" | Cerrado | "12" | Perdido |
| "05" | Evaluando | "13" | Próximo Periodo |
| "07" | Prueba | "14" | Sin WhatsApp |
| | | "15" | Ficha Inscripción |

**Agregar canal nuevo:**
1. Constante de ícono en la clase
2. Color en `_coloresCanal`
3. Ícono en `_iconosCanal`

**Agregar etapa nueva:**
1. Constante de ícono en la clase
2. Color en `_coloresEstado`
3. Fondo en `_bgEstado`
4. Ícono en `_iconosEstado`

---

## AppImages — `constants/app_images.dart`

```dart
AppImages.logoGs1Peru        // 'assets/images/logo_gs1.svg'
AppImages.logoGs1PeruBlanco  // 'assets/images/logo_gs1_blanco.svg'
AppImages.logoGoogle         // 'assets/icons/google_logo.svg'

// Logo según tema — usar siempre este en widgets
AppImages.logoTheme(context)               // necesita BuildContext
AppImages.logoFromBrightness(brightness)   // sin context, para ViewModels
```

---

## AppConstants — `constants/app_constants.dart`

```dart
AppConstants.version    // '1.0'
AppConstants.nombreApp  // 'GS1 Perú - CRM'

// Separadores para body del backend — nunca usar literales de estos caracteres
AppConstants.sepRegistros // '¬' — separa registros en una lista
AppConstants.sepCampos    // '¦' — separa campos de un registro
AppConstants.sepListas    // '¯' — separa secciones en la respuesta
AppConstants.sepComodin   // '¨' — uso libre
AppConstants.sepComodin2  // '±' — uso libre
AppConstants.sepComodin3  // '¶' — uso libre
```

---

## AppBreakpoints — `constants/app_breakpoints.dart`

```dart
AppBreakpoints.mobile       // 600px
AppBreakpoints.tablet       // 900px
AppBreakpoints.desktop      // 1200px
AppBreakpoints.desktopLarge // 1600px
```

---

## AppTheme — `theme/app_theme.dart`

Material 3 activado. No repetir colores o estilos en widgets individuales.

```dart
// En MaterialApp (ya configurado en app_widget.dart)
theme: AppTheme.lightTheme
darkTheme: AppTheme.darkTheme
themeMode: themeMode // controlado por ThemeCubit
```

| Elemento | Configuración |
|---|---|
| AppBar | Fondo `primary`, texto blanco, sin elevación, centrado |
| Scaffold | `background` light / `backgroundDark` dark |
| ElevatedButton | Primary azul, fullWidth, 48px, `radiusMd` |
| OutlinedButton | Borde `primary` 2px, fullWidth, `radiusMd` |
| Inputs | Filled, `radiusMd`, focus 2px primary, padding h16/v18 |
| Cards | Elevación 2, `radiusMd` |
| Dialogs | `radiusLg` |
| Bottom Sheets | `radiusLg` top |
| Snackbars | Floating, `radiusSm` |

**Cambiar comportamiento del AppBar:** editar `appBarTheme` en `app_theme.dart`.
**Cambiar solo dark theme:** editar getter `darkTheme` en `app_theme.dart`.

---

## Widgets custom — `widgets/`

Siempre usar estos. Nunca el widget nativo equivalente.

### CustomPrimaryButton
Botón relleno azul primario.
```dart
CustomPrimaryButton(
  text: 'GUARDAR',
  onPressed: _guardar,
  isLoading: false,   // muestra spinner al true
  isEnabled: true,
  icon: AppIcons.save, // opcional
  // width, height, padding opcionales
)
```

### CustomSecondaryButton
Botón naranja secundario.
```dart
CustomSecondaryButton(
  text: 'EXPORTAR',
  onPressed: _exportar,
  // isLoading, isEnabled, icon, width, height opcionales
)
```

### CustomTextButton
Botón solo texto, mínima jerarquía.
```dart
CustomTextButton(
  text: '¿Olvidaste tu contraseña?',
  onPressed: _irARecuperar,
  // textColor, fontSize, fontWeight, icon opcionales
)
```

### CustomTextField
Input estándar reutilizable.
```dart
CustomTextField(
  label: 'Nombre',
  hint: 'Ej: Juan Pérez',
  controller: _ctrl,
  prefixIcon: const Icon(AppIcons.user),
  validator: (v) => v!.isEmpty ? 'Requerido' : null,
  // helperText, onChanged, onSubmitted, keyboardType,
  // textInputAction, enabled, readOnly, maxLength,
  // maxLines, minLines, suffixIcon, prefixText, suffixText,
  // inputFormatters, autocorrect, textCapitalization,
  // focusNode, obscureText, isUpperCase — todos opcionales
)
```

---

## Utilidades core

### DateFormatter + AppDateFormat

```dart
// Desde String (backend)
"2025-03-27 01:07:41".formatDate(AppDateFormat.shortDate)   // "27/03/2025"
"2025-03-27 01:07:41".formatDate(AppDateFormat.longDate)    // "27 de marzo 2025"
"2025-03-27 01:07:41".formatDate(AppDateFormat.fullTextDate) // "jueves 27 de marzo del 2025"
"2025-03-27 01:07:41".formatDate(AppDateFormat.hourMinute)  // "01:07"
"2025-03-27 01:07:41".formatDate(AppDateFormat.weekdayOnly) // "jueves"
"2025-03-27 01:07:41".formatDate(AppDateFormat.monthOnly)   // "marzo"

// Estilos WhatsApp
"2025-03-27 01:07:41".formatWhatsApp()           // "01:07" / "Ayer" / "miércoles" / "27/03/2025"
"2025-03-27 01:07:41".formatWhatsAppMultimedia() // "Hoy - 01:07" / "Ayer - 01:07"
"2025-03-27 01:07:41".formatConDia()             // "Hoy 01:07" / "Ayer 01:07"
"2025-03-27 01:07:41".formatSinHoy()             // "01:07" si hoy, si no "Ayer 01:07"

// Desde DateTime
DateTime.now().format(AppDateFormat.hourMinute)
DateTime.now().formatWhatsApp()
```

**Agregar formato nuevo:**
1. `date_formats.dart` → agregar al enum `AppDateFormat`
2. `date_formatter.dart` → agregar case en `_resolvePattern`

### ColorUtils

```dart
ColorUtils.fromName('Seguimientos')              // color fijo del mapa interno
ColorUtils.fromName('cualquier texto')           // color consistente por hash
ColorUtils.badgeColor(baseColor)                 // versión oscura para badge
ColorUtils.textColorOn(fondo)                    // blanco o negro según luminancia
ColorUtils.softBackground('Propuesta', brightness) // fondo suave para card
```

### ElapsedTimeUtils

```dart
ElapsedTimeUtils.formatHyM(elapsed)        // "2h 15m"
ElapsedTimeUtils.formatHoMoS(elapsed)      // "45m" / "15s" / "1h"
ElapsedTimeUtils.colorFromElapsed(elapsed) // Color según urgencia:
// < 30min  → verde  (#2E7D32)
// < 60min  → amarillo (#F9A825)
// < 180min → naranja (#E65100)
// ≥ 180min → rojo   (#C62828)
```

### ResponsiveHelper

```dart
ResponsiveHelper.isMobile(context)   // < 600px
ResponsiveHelper.isTablet(context)   // 600–900px
ResponsiveHelper.isDesktop(context)  // > 900px
ResponsiveHelper.isDesktopLarge(context) // > 1200px

ResponsiveHelper.screenPaddingHorizontal(context) // 16/24/32 según dispositivo
ResponsiveHelper.screenPadding(context)           // EdgeInsets completo
ResponsiveHelper.getGridColumns(context)          // 1/2/4
ResponsiveHelper.getValue(context, mobile: 1, tablet: 2, desktop: 4)

// Widget builder
ResponsiveBuilder(
  mobile: (_) => LayoutMobile(),
  tablet: (_) => LayoutTablet(),   // opcional
  desktop: (_) => LayoutDesktop(), // opcional
)

// Imagen responsive (respeta aspect ratio nativo 1900x1200)
ResponsiveImage.asset('assets/banner.png')
ResponsiveImage.network('https://...', maxWidthFraction: 0.8)
```

### LocalDatabase — SQLite

Singleton. Inicializar una vez en `main.dart`:
```dart
await LocalDatabase().init();
```

```dart
final db = LocalDatabase();

// CRUD genérico
await db.upsert(tabla, mapa)           // insert o replace
await db.getAll(tabla)                 // todos los registros
await db.getById(tabla, id)            // por id
await db.delete(tabla, id)             // eliminar uno
await db.clearTable(tabla)             // limpiar tabla completa

// Queries personalizadas
await db.getWhere(tabla, 'campo = ?', [valor])
await db.rawQuery('SELECT ...', args)

// Settings clave-valor
await db.setSetting('theme', 'dark')
await db.getSetting('theme')           // String? — null si no existe
```

**Tablas actuales:**

| Tabla | Descripción |
|---|---|
| `session` | Sesión activa del usuario (solo 1 registro) |
| `settings` | Preferencias clave-valor (tema, etc.) |

**Agregar tabla nueva:**
1. Agregar `CREATE TABLE` en `_onCreate` en `local_database.dart`
2. Si la app ya está instalada → agregar migración en `_onUpgrade` e incrementar `version: X`