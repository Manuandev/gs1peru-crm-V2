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

### CustomPasswordField
Input de contraseña con toggle de visibilidad. Delega a `CustomTextField`.
```dart
CustomPasswordField(
  label: 'Contraseña',
  controller: _pwdCtrl,
  // hint, helperText, validator, onChanged, onSubmitted,
  // textInputAction, enabled, showToggleButton, focusNode — opcionales
)
```

### CustomEmailField
Input de email con validación de formato incluida. Delega a `CustomTextField`.
```dart
CustomEmailField(
  controller: _emailCtrl,
  onSubmitted: (_) => _focusPassword(),
  // label, hint, validator, onChanged, enabled, focusNode — opcionales
)
```

### CustomOutlinedButton
Botón con borde visible, sin relleno. Para acciones secundarias o de cancelar.
```dart
CustomOutlinedButton(
  text: 'CANCELAR',
  onPressed: () => Navigator.pop(context),
  // isLoading, isEnabled, icon, width, height, borderColor, textColor — opcionales
)
```

### CustomGoogleButton
Botón outlined con logo de Google para autenticación.
```dart
CustomGoogleButton(
  onPressed: _handleGoogleLogin,
  isLoading: false,
  // width, height — opcionales
)
```

### AppSnackBar
Snackbar con diseño custom: icono + título + mensaje + barra de progreso animada.
```dart
AppSnackBar.success(context, 'Guardado correctamente', title: 'Éxito');
AppSnackBar.error(context, 'Error al conectar');
AppSnackBar.warning(context, 'Campo requerido');
AppSnackBar.info(context, 'Sincronizando...');

// Genérico con control total
AppSnackBar.show(
  context,
  message: 'Mensaje',
  title: 'Título',             // opcional
  type: SnackType.success,     // success | error | warning | info
  position: SnackPosition.bottom, // top | bottom
  duration: Duration(seconds: 3),
)
```

### AppLoadingView
Vista de carga centrada (spinner). Usar en estados de carga de BLoC.
```dart
const AppLoadingView()
```

### AppEmptyView
Vista de estado vacío con mensaje customizable.
```dart
AppEmptyView(message: 'No hay registros disponibles')
```

### AppErrorView
Vista de error con botón reintentar.
```dart
AppErrorView(
  message: 'Sin conexión al servidor',
  onRetry: _cargarDatos,
)
```

### CustomComboField\<T extends Comboable\>
Dropdown de selección simple. `T` debe implementar el mixin `Comboable`.
```dart
CustomComboField<CampaniaItem>(
  data: state.campanias,     // List<T extends Comboable>
  label: 'Campaña',
  idIndex: 0,                // índice del campo ID en fields
  labelIndex: 1,             // índice del campo a mostrar
  initialValue: '5',         // coincide con fields[idIndex].toString()
  onChanged: (item) { ... },
  // hint, enabled, validator — opcionales
)
```

### CustomComboSearchField
Combo con búsqueda por texto (Autocomplete). Recibe `List<String>` crudas.
```dart
CustomComboSearchField(
  data: crudas,              // ["id¦descripcion", ...]
  label: 'Oportunidad',
  displayIndex: 1,
  initialValue: '10',        // id inicial
  onChanged: (item) { ... },
  maxSuggestions: 6,
  // separator, hint, enabled, validator — opcionales
)
```

### CustomComboMultiField
Combo multi-selección con chips. Abre diálogo con checkboxes.
```dart
CustomComboMultiField(
  data: crudas,
  label: 'Intereses',
  initialValues: ['1', '3'],
  onChanged: (items) { ... },  // List<ComboItem>
  // separator, displayIndex, hint, enabled, validator — opcionales
)
```

### CustomComboMultiSearchField
Combo multi-selección con buscador en el diálogo (igual que Multi + campo de búsqueda).
```dart
CustomComboMultiSearchField(
  data: crudas,
  label: 'Intereses',
  initialValues: ['1'],
  onChanged: (items) { ... },
)
```

### DrawerItemModel + DrawerSide + AppBarPopupItem
Modelos de configuración para el drawer y el popup del AppBar.
```dart
enum DrawerSide { left, right, none }

DrawerItemModel(
  id: AppRoutes.leads,          // usado para marcar ítem activo
  icon: AppIcons.users,         // IconData o IconDataSocial
  label: 'Leads',
  route: AppRoutes.leads,       // o onTap: () { ... }
  badge: 5,                     // badge numérico opcional
  showDividerAfter: true,
)

AppBarPopupItem(
  value: 'refresh',
  icon: AppIcons.refresh,
  label: 'Actualizar',
  showDividerAfter: false,
)
```

### CustomAppBar
AppBar completamente personalizable con drawer, búsqueda, notificaciones y popup.
```dart
CustomAppBar(
  title: 'Leads',                    // o titleWidget: Widget
  drawerSide: DrawerSide.left,       // left | right | none
  onSearch: (query) { ... },         // activa campo de búsqueda en AppBar
  notificationCount: 3,              // null=oculto | 0=sin badge | >0=badge+pulso
  onNotification: () { ... },
  trailingButtons: [IconButton(...)],
  popupItems: [AppBarPopupItem(value: 'export', icon: AppIcons.download, label: 'Exportar')],
  onPopupSelected: (value) { ... },
)
```

### AppDrawerWidget
Drawer con header de usuario, ítems navegables, badges y logout. Consume `DrawerBloc`.
```dart
AppDrawerWidget(
  items: AppMenuItems.withBadges(conversacionesBadge: 3),
  showSettings: true,
  showLogout: true,
  onSettings: () { ... },    // null = navega a AppRoutes.settings automáticamente
)
```

### ExitOnBackWrapper
Envuelve un widget para mostrar diálogo de confirmación al salir de la app.
```dart
ExitOnBackWrapper(child: MyHomePage())
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

---

## ApiConstants — `constants/api_constants.dart`

Centraliza todas las URLs y endpoints. Las URLs se componen de `EnvConfig.baseUrl + ruta`.

```dart
// Bases (desde EnvConfig — nunca hardcodear)
ApiConstants.baseUrl        // URL base REST
ApiConstants.urlArchivos    // URL de archivos/multimedia
ApiConstants.urlWebSocket   // URL SignalR

// Endpoints (segmento de ruta — patrón: LST = lectura, CUD = create/update/delete)
ApiConstants.login / loginGoogle
ApiConstants.lstListas
ApiConstants.lstleads / cudleads
ApiConstants.lstChats / listarChats / detalleChat / enviarMensaje / guardarMultimedia
ApiConstants.lstProspectos / cudProspectos
ApiConstants.lstPropuestas / cudPropuestas
ApiConstants.lstCobranzas / cudCobranzas

// URLs completas (helpers — usan baseUrl automáticamente)
ApiConstants.urlLogin / urlLoginGoogle
ApiConstants.urlLeadsLst / urlLeadsCud
// ... y así para todos los módulos
```

---

## AppMenuItems — `constants/app_menu_items.dart`

Un único lugar donde viven todos los ítems del drawer. Si cambia una ruta o ícono, solo se cambia aquí.

```dart
// Lista fija (sin badges)
AppMenuItems.mainItems    // [home, Conversaciones, Seguimiento, Propuestas, Cobranza]

// Con badges dinámicos (preferir en producción)
AppMenuItems.withBadges(
  conversacionesBadge: 3,
  prospectosBadge: null,     // null = no muestra badge
  propuestasBadge: 1,
  cobranzaBadge: null,
)

// Ítem individual pre-construido
AppMenuItems.home   // DrawerItemModel del inicio
```

**Agregar módulo nuevo:**
1. Definir constante estática en `AppMenuItems`
2. Agregarla a `mainItems` y al método `withBadges()`

---

## ThemeCubit — `theme/theme_cubit.dart`

Persiste el `ThemeMode` en SQLite. Emite siempre `ThemeMode.light` por ahora (dark en desarrollo).

```dart
// En main() — cargar antes de runApp
await themeCubit.loadSavedTheme();

// En pantalla de configuración — cuando se implemente
context.read<ThemeCubit>().setTheme(ThemeMode.dark);
```

Estado emitido: `ThemeMode` (light / dark / system).

---

## Modelos core — `models/`

### UserModel — `models/user_model.dart`
Datos del usuario autenticado. Vive **solo en memoria** (no se persiste en SQLite).

```dart
user.userId / token / codUser / userApe / correoUser
user.telefono / celular / isModerador
user.fullName   // alias de userApe para mostrar en UI

// Parser (llamado internamente por el feature de auth)
UserModel.fromRawString(rawResponse)
```

### ComboItem — `models/combo_item.dart`
Modelo genérico para todos los dropdowns. Soporta N campos separados por `¦`.

```dart
ComboItem.fromRaw('001¦Gerente¦GER')  // parsea string crudo
ComboItem.fromList(dataList)           // parsea lista de strings

item.id           // campo 0 — siempre presente
item.descripcion  // campo 1 — siempre presente
item.value(2)     // campo extra índice 2 (nullable)
item.field(n)     // acceso genérico por índice 0-based
item.fieldCount   // total de campos
```

### Catálogos — `models/catalog_item.dart`

| Clase | Campos |
|---|---|
| `ListasGenericas` | campanias, oportunidades, canales, intereses |
| `CampaniaItem` | id(int), nombre |
| `OportunidadItem` | idEvento(int), idCampania(int), nombre |
| `CanalItem` | id(int), nombre |
| `InteresItem` | id(int), nombre |

Todas implementan `Comboable`. Parsear con `ListasGenericasModel.parse(rawResponse)`.

---

## Errores — `errors/app_exception.dart`

```dart
// Excepción genérica de la app — usar en datasources y usecases
throw AppException('Token inválido');

// Solo en el flujo de login — para re-llenar el formulario con credenciales guardadas
throw SessionNotRememberedException(username, password);
```

---

## Domain — `domain/`

### Mixin Comboable — `mixins/comboable.dart`
Marca una clase como compatible con `CustomComboField<T>`.
```dart
class CampaniaItem with Comboable {
  @override
  List<dynamic> get fields => [id, nombre];  // orden: id primero, label segundo
}
```

### Enums — `domain/enums/enums_core.dart`
```dart
enum ImageSourceType { asset, network }
```

### GetCatalogsUseCase — `domain/usecases/get_catalogs_usecase.dart`
Obtiene las listas genéricas (campañas, oportunidades, canales, intereses).
```dart
final listas = await GetCatalogsUseCase(repository).call();
```

---

## Servicios core — `services/`

### SessionService — `services/session_service.dart`
Singleton en memoria. El único lugar donde viven los datos del usuario autenticado.
```dart
final session = SessionService();  // singleton

session.setUser(userModel)   // al hacer login exitoso
session.clear()              // al hacer logout

session.user         // UserModel? (null si no hay sesión)
session.token        // String del token
session.codUser      // código del usuario
session.userApe      // nombre/apellido
session.isModerador  // bool
session.hasSession   // bool
```

### DeviceInfoService — `services/device_info_service.dart`
Recoge información del dispositivo, SO y GPS. Usar siempre el caché estático.

```dart
// Llamar en Splash — precarga GPS en background (no bloquea)
DeviceInfoService.precargarEnBackground();

// En datasource de login — usa el caché, timeout de 3s como fallback
final info = await DeviceInfoService.getInfoConTimeout();
// info['coordenadas'], info['modelo'], info['so'], info['ciudad'], ...

// Acceso individual (retorna caché si ya se obtuvo)
await DeviceInfoService().getCoordinates()        // CoordinatesResult
await DeviceInfoService().getUbicacionCompleta()  // UbicacionResult
```

**UbicacionResult:** pais, paisCodigo, region, provincia, ciudad, distrito, calle, numero, codigoPostal  
**CoordinatesResult:** latitud, longitud, altitud, precision, coordsString

### CatalogsRepository / CatalogsRepositoryImpl
Contrato e implementación para obtener listas genéricas del backend. Consumir solo a través de `GetCatalogsUseCase` o `CatalogsBloc`.

---

## Network — `network/`

### ApiClient — `network/api_client.dart`
Singleton Dio. Todos los datasources lo usan. Nunca instanciar Dio directamente.

```dart
final client = ApiClient();   // singleton

client.setToken(token)        // al hacer login
client.clearToken()           // al hacer logout

// Métodos de petición
await client.postJsonGetText(url, body)   // retorna String crudo
await client.postSafe(url, body)          // retorna ApiResult<String>
await client.postMultipart(url: ..., fields: ..., fileFieldName: ..., fileBytes: ..., fileName: ...)
```

**Interceptores integrados (en orden de ejecución):**
1. `TokenBodyInterceptor` — prepende `token¯` al body antes de enviar
2. `CleanResponseInterceptor` — quita comillas extra que agrega ASP.NET
3. `ErrorInterceptor` — convierte DioException en AppException
4. `LogInterceptor` — solo en debug mode

### ApiResult\<T\> — `network/api_result.dart`
Resultado sealed de una llamada REST. Nunca usar `null` ni excepciones raw.

```dart
switch (result) {
  case ApiSuccess<String>(:final data) => _parsear(data),
  case ApiEmpty()                       => _sinDatos(),
  case ApiNoInternet()                  => _sinInternet(),
  case ApiError(:final message)         => _mostrarError(message),
}
```

### CrudResult — `network/crud_result.dart`
Resultado sealed de operación CUD. Parsea la respuesta del backend.

```dart
final raw = await client.postJsonGetText(url, body);
final result = parseCrudResponse(raw);   // función top-level

switch (result) {
  case CrudOk(:final message)    => _exito(message),
  case CrudAlert(:final message) => _alerta(message),
  case CrudError(:final message) => _error(message),
  case CrudNoInternet()          => _sinInternet(),
  case CrudEmpty()               => _sinRespuesta(),
}
```

---

## WebSocket / SignalR — `network/websocket/`

### Arquitectura

```
SignalRService (singleton)
  └─ gestiona conexión / reconexión / heartbeat
  └─ parsea mensajes con WebSocketMessageParser
  └─ pasa al MessageDispatcher

MessageDispatcher (singleton)
  └─ switch por message.process
  └─ decide si mostrar notificación según ruta activa
  └─ emite al stream público (features escuchan aquí)
```

### SignalRService — `network/websocket/connection/signalr_service.dart`
```dart
// Ciclo de vida (manejado por el feature de auth)
await SignalRService.instance.connect()
await SignalRService.instance.close()      // logout — no reconecta
await SignalRService.instance.reset()      // para reconectar desde cero
await SignalRService.instance.forceReconnect()

// Estado en tiempo real
SignalRService.instance.connectionStateStream  // Stream<WebSocketConnectionState>
SignalRService.instance.currentState
SignalRService.instance.isConnected

// Enviar mensaje al hub
SignalRService.instance.sendMessage(json)  // retorna bool (éxito/fallo)

// FCM — automático al conectar / desconectar
await SignalRService.instance.limpiarTokenFCM()   // llamar al logout
```

**Reconexión:** backoff exponencial (500ms → 1s → 2s → 5s → 10s), luego pausa de 1 minuto por ciclo.

### MessageDispatcher — `network/websocket/connection/message_dispatcher.dart`
Las features filtran mensajes por proceso:
```dart
MessageDispatcher.instance.stream
  .where((msg) => msg.process == 'MENSAJE_WHATSAPP')
  .listen(_handleMensaje);
```

### WebSocketConnectionState — enum
`connected` · `disconnected` · `connecting` · `reconnecting` · `manuallyClosed` · `noInternet`

### WebSocketMessage — `network/websocket/parser/websocket_message.dart`
```dart
msg.process      // "MENSAJE_WHATSAPP", "UPDATE_PANTALLA_WHATSAPP", ...
msg.records      // List<List<String>> — registros parseados (¬ = separador de registros)
msg.firstRecord  // shortcut al primer registro
msg.receivedAt   // DateTime de recepción
```

### Payloads — `network/websocket/payloads/`

| Clase | Proceso | Cuándo llega |
|---|---|---|
| `WhatsAppMessagePayload` | `MENSAJE_WHATSAPP` | Mensaje nuevo del cliente |
| `UpdatePantallaWhatsAppPayload` | `UPDATE_PANTALLA_WHATSAPP` | Confirmación de mensaje enviado |
| `UpdateMensajeWhatsAppPayload` | `UPDATE_MENSAJE_WHATSAPP` | Cambio de estado (checks) |

```dart
final payload = WhatsAppMessagePayload.fromMessage(wsMessage);
// payload?.mensaje / leadId / tipoMensaje / idMensaje / codAsesor / flgCerrado / ...
```

**Agregar proceso nuevo:**
1. Añadir case en `MessageDispatcher.dispatch()`
2. Crear payload class en `payloads/` si necesita parseo complejo
3. La feature se suscribe a `MessageDispatcher.instance.stream`

---

## Notificaciones — `notifications/`

### Flujo

```
Backend → FCM (background) ──────────────────┐
                                             ▼
Backend → SignalR → MessageDispatcher → NotificationHandler
                                             │
                              LocalNotificationService.showWhatsApp()
                                             │
                              Al tocar → NotificationNavigator.navigate()
```

### NotificationService — `notifications/services/notification_service.dart`
Coordinador de todos los servicios de notificación.
```dart
await NotificationService.instance.init()               // en main()
await NotificationService.instance.initBackground()     // en handler background
await NotificationService.instance.requestPermissions() // en Splash (hay UI)
await NotificationService.instance.cancelAll()          // al logout
```

### AppNotification — `notifications/models/app_notification.dart`
```dart
AppNotification(
  title: 'Nuevo mensaje',
  body: 'Hola, ¿cómo está?',
  route: AppRoutes.detalleChat,       // ruta al tocar la notif
  payload: {'idLead': '42'},          // datos extras
)
```

### NotificationHandler — `notifications/handlers/notification_handler.dart`
Decide si mostrar o suprimir una notificación según la ruta activa (evita duplicados).
- Suprime `MENSAJE_WHATSAPP` si el usuario ya está viendo esa lista o ese chat específico.

### NotificationNavigator — `notifications/handlers/notification_navigator.dart`
Navega a la pantalla correcta al tocar la notificación (desde background/killed).
```dart
NotificationNavigator.instance.navigate(notif)  // interno — llamado por Firebase service
```

### FirebaseNotificationService — `notifications/services/firebase_notification_service.dart`
Gestiona FCM: permisos, token, mensajes en foreground/background/killed.
```dart
await FirebaseNotificationService.instance.obtenerToken()  // String? token FCM
```

Registrar el handler de background en `main()`:
```dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

---

## BLoCs core — `presentation/bloc/`

### DrawerBloc — `presentation/bloc/drawer/`
Maneja el estado del drawer (datos de usuario + badges de módulos).

**Eventos:**
- `DrawerStarted` — carga datos instantáneamente desde `SessionService` (sin async)
- `DrawerBadgesUpdated` — actualiza contadores (conversaciones, prospectos, propuestas, cobranzas)

**Estados:**
- `DrawerIdle` — antes del login
- `DrawerLoaded` — con userName, userApe, userSubtitle y badges

```dart
// Disparar al entrar a home
context.read<DrawerBloc>().add(DrawerStarted());

// Actualizar badges desde cualquier feature (usa BadgeExtension)
context.updateBadge(conversaciones: 3, propuestas: 1);
```

### CatalogsBloc — `presentation/bloc/catalog/`
Carga las listas genéricas del backend una sola vez al inicio de sesión.

**Evento:** `CatalogsLoadRequested`

**Estados:** `CatalogsInitial` → `CatalogsLoading` → `CatalogsLoaded` | `CatalogsError`

```dart
// Acceso en widgets
final state = context.watch<CatalogsBloc>().state;
if (state is CatalogsLoaded) {
  final campanias = state.campanias;   // List<CampaniaItem>
  final canales = state.canales;       // List<CanalItem>
  final intereses = state.intereses;   // List<InteresItem>
  final opors = state.oportunidades;   // List<OportunidadItem>
}
```

---

## Páginas core — `presentation/pages/`

### BasePage — `presentation/pages/base_page.dart`
Layout base para **todas las pantallas del home**. Arma AppBar + Drawer + Body + Footer automáticamente.

```dart
BasePage(
  title: 'Leads',                               // o titleWidget: Widget
  drawerSide: DrawerSide.left,                  // left | right | none
  body: LeadsView(),

  // AppBar — todos opcionales
  appBarTrailingButtons: [IconButton(...)],
  appBarPopupItems: [AppBarPopupItem(...)],
  onPopupSelected: (value) { ... },
  onSearch: (query) { ... },                    // activa buscador en AppBar

  // Drawer — todos opcionales
  drawerItems: AppMenuItems.withBadges(...),
  showDrawerSettings: true,
  showDrawerLogout: true,
  onSettings: () { ... },

  // Layout — todos opcionales
  footer: MyFooter(),                           // null = footer estándar
  floatingActionButton: FloatingActionButton(...),
  bodyPadding: EdgeInsets.zero,                 // null = padding estándar md
  onPop: () => context.goToHome(),              // intercepta el back button
  backgroundColor: AppColors.background,
)
```

El **footer estándar** muestra: `{nombreApp} - v{version}` + chip de estado SignalR (● En línea / ● Reconectando / ● Sin internet).

### UnderConstructionPage — `presentation/pages/under_construction_page.dart`
Placeholder animado para rutas aún no implementadas. Usa `BasePage`.
```dart
UnderConstructionPage(routeName: 'Reportes')
```

---

## Navegación core — `navigation/`

### AppRouteObserver — `navigation/app_route_observer.dart`
Singleton que trackea la ruta activa y el lead abierto en el chat. Usado por `MessageDispatcher` y `NotificationHandler` para suprimir notificaciones cuando la pantalla ya está visible.

```dart
// Registrar en MaterialApp (ya configurado en app_widget.dart)
navigatorObservers: [AppRouteObserver.instance]

// En ChatDetailPage — informar qué lead está abierto
AppRouteObserver.instance.setActiveLead(leadId);  // initState
AppRouteObserver.instance.setActiveLead(null);    // dispose

// Leer desde cualquier lugar
AppRouteObserver.instance.currentRoute   // String? ruta actual
AppRouteObserver.instance.activeLeadId  // int? lead en detalle chat
```

---

## Mixins — `mixins/`

### DoubleBackToExitMixin — `mixins/double_back_to_exit_mixin.dart`
Requiere doble back press en 2s para salir de la app. Alternativa a `ExitOnBackWrapper`.
```dart
class _HomeState extends State<HomePage> with DoubleBackToExitMixin {
  // el mixin provee onWillPop() — conectarlo a PopScope/WillPopScope
}
```

---

## Extensions — `extensions/`

### BadgeExtension on BuildContext — `extensions/badge_extensions.dart`
Actualiza los badges del drawer desde cualquier feature sin acceder directamente al BLoC.
```dart
context.updateBadge(
  conversaciones: 3,
  prospectos: 1,
  propuestas: null,   // null = no cambia el valor actual
  cobranza: 0,
)
```

---

## Helpers — `helpers/`

### CanalHelper — `helpers/canal_helper.dart`
Alternativa a `AppIconsSocial` usando iconos **Material** (no FontAwesome). Útil cuando no se puede usar `FaIcon`.

```dart
final info = CanalHelper.get(1)   // CanalInfo para WhatsApp
info.nombre  // 'WhatsApp'
info.icon    // Icons.message (MaterialIcons)
info.color   // Color(0xFF25D366)

// Widget listo
CanalHelper.icon(1, size: AppSizing.iconMd)  // Icon con color correcto
```

Preferir `AppIconsSocial` en la mayoría de casos. Usar `CanalHelper` cuando se necesiten `Icon` nativos.

---

## Utils adicionales — `utils/`

### AvatarUtils + StringAvatarX — `utils/ui/avatar_utils.dart` + `utils/ui/avatar_extensions.dart`

```dart
// Estático
AvatarUtils.initials('Juan Pérez')   // "JP"
AvatarUtils.color('Juan Pérez')      // Color consistente por nombre

// Extension on String
'Juan Pérez'.initials     // "JP"
'Juan Pérez'.avatarColor  // Color
```

### StringExtensions / NullableStringExtensions — `utils/string/string_utils.dart`

```dart
'+51 999 888 777'.limpiarTelefono   // '+51999888777' — quita espacios y guiones
'hola'.convertToHex                 // representación hexadecimal del string

// Validador de email (para usar en validators de formularios)
null.emailValidator          // 'El email es requerido'
'abc@'.emailValidator        // 'Ingresa un email válido'
'abc@mail.com'.emailValidator // null (válido)
```

### LauncherUtils — `utils/launcher/launcher_utils.dart`

```dart
await LauncherUtils.abrirTelefono('999888777');
await LauncherUtils.abrirCorreo(
  'cliente@mail.com',
  asunto: 'Propuesta GS1',
  cuerpo: 'Estimado...',
)
```