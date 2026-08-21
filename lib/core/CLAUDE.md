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
| `constants/app_icons.dart` | Todos los íconos: Material (`IconData`) + FontAwesome (`FaIconData`) |
| `utils/ui/social_utils.dart` | `AppSocialUtils` — colores, mapas y widgets de canal/estado CRM |
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

## AppIcons — íconos FA (canales + etapas)

Los íconos FontAwesome también viven en `AppIcons`. Usar con `FaIcon()` o `resolveIcon()`.

```dart
// Canales
AppIcons.whatsapp / tiktok / instagram / facebook / linkedin
AppIcons.web / instapage / bocaBoca / migracion / referido / manual

// Etapas
AppIcons.etapaNuevo / etapaEnDesarrollo / etapaPropuesta / etapaFicha
AppIcons.etapaCerrado / etapaEvaluando / etapaPrueba / etapaPendiente
AppIcons.etapaSinRespuesta / etapaDesiste / etapaGanado / etapaPerdido
AppIcons.etapaProximoPeriodo / etapaSinWhatsapp / etapaFichaInscripcion
```

## AppSocialUtils — `utils/ui/social_utils.dart`

Colores y widgets listos para canales y etapas CRM.

```dart
AppSocialUtils.widgetCanal(id, size: 14)    // FaIcon con color de marca
AppSocialUtils.widgetEstado(id, size: 14)   // FaIcon con color de etapa
AppSocialUtils.chipEstado(id, label: '...')  // Chip bg + color de etapa
AppSocialUtils.colorCanal(id)               // Color del canal
AppSocialUtils.colorEstado(id)              // Color del estado
AppSocialUtils.bgEstado(id)                 // Color de fondo del estado

AppSocialUtils.widgetCanalExpoById(id, size: 14) // FaIcon del canal expo (EDU_CANAL_EXPO)
AppSocialUtils.colorCanalExpoById(id)            // Color del canal expo
```

**Canales (id int):** 1=WhatsApp 3=TikTok 4=Instagram 5=Facebook 6=LinkedIn 7=Web 8=Instapage 9=BocaBoca 10=Migración 11=Referido 12=Manual

**Etapas (id string):** "00"=Nuevo "01"=EnDesarrollo "02"=Propuesta "03"=Ficha "04"=Cerrado "05"=Evaluando "07"=Prueba "08"=Pendiente "09"=SinRespuesta "10"=Desiste "11"=Ganado "12"=Perdido "13"=ProximoPeriodo "14"=SinWhatsApp "15"=FichaInscripcion

**Canal expo (id int, `CanalExpoItem`/`dbo.EDU_CANAL_EXPO` — catálogo aparte del canal de
origen del lead de arriba, "¿Cómo se enteró del evento?" en `solicitudes/`):**
1=Facebook 2=LinkedIn 3=Instagram 4=Logística ⚠️ ya no lo devuelve el SP como opción activa,
solo queda mapeado para solicitudes viejas que ya lo tengan guardado 5=Logística 360 6=Otros —
usar `widgetCanalExpoById`, nunca `widgetCanalById` (mapa de canal de lead, ids distintos —
mismo id puede significar otro canal).

**Agregar canal nuevo:**
1. Ícono `FaIconData` en `AppIcons`
2. Color en `AppSocialUtils._coloresCanal`
3. Ícono en `AppSocialUtils._iconosCanal`

**Agregar canal expo nuevo:**
1. Ícono `FaIconData` en `AppIcons` (sección "CANAL EXPO")
2. Id → key en `AppSocialUtils._idAIconoAppCanalExpo`
3. Color en `AppSocialUtils._coloresCanalExpo`
4. Ícono en `AppSocialUtils._iconosCanalExpo`

**Agregar etapa nueva:**
1. Ícono `FaIconData` en `AppIcons`
2. Color en `AppSocialUtils._coloresEstado`
3. Fondo en `AppSocialUtils._bgEstado`
4. Ícono en `AppSocialUtils._iconosEstado`

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
`mostrarBotonLimpiar: true` (default `false`, requiere `controller`) agrega un ícono "X" que
limpia el campo cuando tiene texto — mismo patrón que ya usa `CustomComboSearchField`. Agregado
2026-07-22, disponible en cualquier campo pero **apagado por defecto en toda la app** — pedido
explícito del usuario, se activa manualmente campo por campo cuando se decida cuáles lo
necesitan (ningún campo lo tiene activado todavía). Se ignora si ya se pasó un `suffixIcon`
propio.

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

### AppProcessOverlay
Overlay de pantalla completa para operaciones asíncronas, con marca GS1 (logo con resplandor +
puntos animados) — **único overlay de carga de toda la app, usar siempre este, nunca un
`CircularProgressIndicator`/spinner genérico suelto**. Dos estados: `AppProcessStatus.cargando`
("Guardando/Subiendo/Buscando..." — logo pulsando) y `.exito` (check verde animado), con
transición animada entre ambos (`AnimatedSwitcher` + scale/fade). Generaliza el patrón "loading
card → check card" que antes se repetía a mano por pantalla (ver `lead/CLAUDE.md` →
`EditLeadPortrait`, primer caller real, agregado 2026-08-03) — pensado para cualquier flujo con
el mismo patrón: guardar formularios, subir archivos/multimedia, buscar datos de un documento,
etc. El estado "cargando" usa `AppImages.logoTheme(context)` pulsando (0.88↔1.0) en el centro del
`CircularProgressIndicator` de siempre — mismo lenguaje visual que el logo pulsando de Splash
(`auth/splash_portrait.dart._pulseController`) pero en tamaño compacto (72px, cabe en la
tarjeta, no ocupa la pantalla como el splash). El check usa una animación propia (círculo
`easeOutBack` + ícono `elasticOut` con delay, `_CheckAnimado` interno) en vez de un ícono
estático.
```dart
Stack(
  children: [
    MiFormulario(),
    if (_status != null)
      AppProcessOverlay(
        status: _status!,             // AppProcessStatus.cargando | .exito
        loadingMessage: 'Guardando...',
        successMessage: 'Se guardó correctamente',
      ),
  ],
)
```
El caller decide cuándo mostrar `exito` (ej. tras confirmar el guardado) y cuándo dejar de
renderizar el overlay — el widget solo anima la transición entre sus 2 estados, no controla
temporizadores de auto-cierre (eso sigue siendo responsabilidad del caller, ver
`EditLeadPortrait._setGuardando()`/`_guardar()`).

**Búsquedas cortas (autocompletado por documento/RUC) — solo el estado `cargando`, sin `exito`
(2026-08-12).** Antes estas búsquedas usaban `AppLoadingOverlay` (spinner genérico + mensaje,
widget aparte) — reemplazado por pedido explícito del usuario ("la misma pantalla de carga de
GS1 en todos lados"), `AppLoadingOverlay` **se eliminó del proyecto** (quedó sin ningún uso real
tras este cambio). Para una búsqueda corta que no tiene un paso de "éxito" que celebrar (el
resultado simplemente rellena los campos, no hay nada que confirmar con un check), pasar solo
`status: AppProcessStatus.cargando` y dejar de renderizar el overlay apenas termina la búsqueda —
nunca transicionar a `.exito` para este caso, sería un paso extra sin motivo:
```dart
Stack(
  children: [
    MiFormulario(),
    if (_buscando)
      const AppProcessOverlay(
        status: AppProcessStatus.cargando,
        loadingMessage: 'Buscando datos del documento...',
      ),
  ],
)
```
Usado así en `solicitudes/` (Número documento del solicitante, RUC de Información comercial,
Facturación, N° documento del formulario de participante — ver `solicitudes/CLAUDE.md` →
"Autocompletado por documento") y en `lead/` (`EditContacto`/`EditContactoSimple`, búsqueda de
documento y de RUC). Si se agrega una búsqueda nueva en cualquier feature, seguir este mismo
patrón — no reintroducir un spinner genérico ni un overlay propio por pantalla.

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

**`initialValue` se resincroniza en `didUpdateWidget`, no solo en `initState()`.** Si un combo se
autoselecciona programáticamente (ej. Moneda cambiando al elegir Oportunidad en
`lead/edit_lead_portrait.dart`), el nuevo `initialValue` que llega desde el padre se refleja en la
selección visible aunque el widget ya esté montado — antes solo se leía una vez en `initState()` y
quedaba visualmente congelado en el primer valor pese a que el estado del padre sí cambiaba. Esto
aplica también con `enabled: false` (combo deshabilitado pero cuyo valor mostrado igual debe
actualizarse desde afuera).

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
Al tocar una coincidencia de la lista, el campo pierde el foco y cierra el teclado
automáticamente (fix 2026-07-22 — antes se quedaba enfocado tras elegir una opción). El botón
"check"/listo del teclado mantiene el comportamiento por defecto de Flutter (cierra
teclado/foco), sin cambios — no confundir ambos casos, **salvo con `allowFreeText: true`** (ver
abajo), donde ese mismo botón sí dispara lógica propia.

**`allowFreeText: true`** (agregado 2026-08-03, apagado por defecto — no afecta a ningún campo
existente) — permite que el valor final sea texto libre si no matchea ningún ítem del catálogo:
```dart
CustomComboSearchField(
  data: cargos.map((c) => '${c.id}¦${c.nombre}').toList(),
  label: 'Cargo',
  allowFreeText: true,
  initialText: row.cargo,        // texto ya guardado — en vez de initialValue (id)
  onChanged: (item) => row.cargo = item?.descripcion ?? '',  // item.id vacío si es texto libre
)
```
El combo sigue mostrando/filtrando las sugerencias del catálogo como siempre; la diferencia está
en qué pasa al confirmar (botón "check"/done del teclado, `onFieldSubmitted`): si el texto
tipeado matchea una sugerencia (sin distinguir mayúsculas) se resuelve como selección normal
(conserva `id`); si no matchea nada, igual se manda como `ComboItem(id: '', descripcion: texto)`
— el caller debe leer `item?.descripcion`, no `item?.id`, para no perder el valor libre. Usar
`initialText` (no `initialValue`) cuando lo que se carga ya es el texto guardado y no un id de
catálogo — ver Área/Cargo en `lead/CLAUDE.md`. Tocar afuera del campo sin presionar el check NO
confirma el texto libre (a propósito, replica "aprieto el check del teclado" tal como se pidió,
no cualquier pérdida de foco).

**`allowFreeText: true` + `validator` (Cargo de `solicitudes/`, agregado 2026-08-04)** — el
`validator` interno del widget compara contra `_selected?.id` por defecto (correcto cuando el
campo exige una selección real del catálogo, como cualquier combo sin `allowFreeText`), pero con
texto libre confirmado `_selected.id` queda vacío a propósito (`ComboItem(id: '', descripcion:
texto)`) — validar por id ahí marcaba "Requerido" aunque el asesor sí hubiera tipeado y
confirmado algo. Con `allowFreeText: true` el widget valida contra `_selected?.descripcion` en
su lugar (sin id no matcheado, con texto libre confirmado sí). Los usos existentes de
`allowFreeText` (Área/Cargo de `lead/EditContacto`) nunca pasaban `validator` (campos opcionales),
así que no cambiaron de comportamiento — este ajuste solo importa para un combo con texto libre
que además sea obligatorio.

**`allowFreeText: true` sincroniza en vivo, no solo al confirmar (2026-08-12)** — antes,
`widget.onChanged` solo se disparaba al tocar una sugerencia de la lista (`onSelected`) o al
presionar el check ✓ del teclado (`onFieldSubmitted` → `_commitFreeText`). Bug real reportado en
Cargo de `solicitudes/`: si el asesor seleccionaba una sugerencia y le agregaba una letra más sin
presionar ese check (ej. tocando directo el botón "Siguiente"/"Guardar" del formulario), esa
edición nunca llegaba al padre — el valor guardado seguía siendo el de la sugerencia original,
sin la letra agregada. Corregido con un listener sobre el `TextEditingController` interno del
`Autocomplete` (capturado una sola vez por instancia real de controller —
`fieldViewBuilder` se reconstruye en cada build, hay que evitar engancharlo de nuevo cada vez) —
`_syncFreeText(text)` corre en cada tecla, resolviendo match/texto libre igual que
`_commitFreeText`, pero sin cerrar el teclado (eso sigue siendo exclusivo de confirmar con el
check o tocar una sugerencia). Efecto: lo que esté escrito en el campo en el momento de
guardar ya es lo que se manda, sin depender de que el asesor presione el check. Aplica a
cualquier uso de `allowFreeText: true` — Cargo de `solicitudes/` y Área/Cargo de
`lead/EditContacto` por igual, mismo widget.

**Bug real — `didUpdateWidget` borraba el texto libre confirmado en CUALQUIER rebuild del padre,
mostrando "Requerido" pese a que el campo seguía con el texto tipeado (Cargo de `solicitudes/`,
2026-08-12).** Repro exacto del usuario: paso 1 del wizard, Cargo con texto libre (no matchea el
catálogo), presiona "Siguiente" → el campo se marca "Requerido" aunque el texto sigue visible.
Causa, en `didUpdateWidget`: (1) `old.data != widget.data` compara **listas por referencia** —
el caller típico arma `data` con `.map().toList()` dentro de su propio `build()` (ej.
`SeccionDatosSolicitante`), así que llega una instancia nueva en CADA rebuild del padre aunque el
contenido no cambió; (2) `_onContinuar()` (`solicitud_completar_view_guardado.dart`) hace
`setState(() => _autovalidar = true)` **antes** de `_formKey.currentState?.validate()` — ese
`setState` reconstruye todo el árbol, regenerando la lista `data` de Cargo, lo que dispara el
`if` de arriba; (3) con texto libre confirmado, `_selected.id` es `''` a propósito (ver arriba) —
ningún `CargoItem` real tiene id vacío, así que `_allItems.any((e) => e.id == _selected!.id)` da
`false` y **`_selected` se pone en `null`** justo antes de que corra `validate()`. Corregido con
2 cambios en `didUpdateWidget`: **(a)** `listEquals(old.data, widget.data)` (por contenido, de
`package:flutter/foundation.dart`) en vez de `!=` (por referencia) — ya no dispara el bloque en
cada rebuild ajeno sin cambios reales; **(b)** el reset de `_selected` ahora solo aplica si
`_selected!.id.isNotEmpty` — una selección de texto libre (`id` vacío) nunca se borra solo porque
la lista del catálogo se haya reconstruido, únicamente cuando `_selected` venía de un id real del
catálogo que ya no está en la lista nueva (ese caso sí debe seguir reseteando, ej. el catálogo se
recargó y el ítem elegido ya no existe). Afecta a cualquier uso de `allowFreeText: true` con
`data` regenerado en cada build del padre — mismo widget que Cargo/Área de `lead/EditContacto`.

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
await db.deleteSetting('theme')        // elimina la clave
```

Uso real de settings más allá de preferencias: `notifications/` persiste ahí los mensajes de
WhatsApp no leídos por número (`notif_msgs_{idNumero}`, ver `notifications/CLAUDE.md`) — necesario
porque el handler de FCM en background corre en un isolate nuevo por cada push con la app
cerrada, y un `Map` en memoria perdería el conteo entre uno y otro.

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

### Catálogos — `models/catalog_item.dart` + `models/catalog_item_model.dart`

Clases base (sin parseo) en `catalog_item.dart`; clases `*Model` (`fromRawString`/`parseList`,
usadas por `ListasGenericasModel.parse`) en `catalog_item_model.dart`. Ambos se exportan desde
`index_core.dart` — importar siempre por ahí, nunca los archivos individuales.

| Clase | Campos |
|---|---|
| `ListasGenericas` | campanias, oportunidades, canales, intereses, estados, asesores, estadosGestion, monedas, igvPorcentaje, paises, tiposDocumento, comprobantes, nacionalidades, valoresDefecto |
| `CampaniaItem` | id(int), nombre |
| `OportunidadItem` | idEvento(int), idCampania(int), nombre |
| `CanalItem` | id(int), nombre |
| `InteresItem` | id(int), nombre |
| `EstadoItem` | id(String), nombre, idPadre(String?) — parte [4] del SP, estados de `lead/` (jerárquico) |
| `AsesorItem` | codUser(String), nombre(String), disponible(bool) — parte [5] del SP; universo = todo `CODUSER` que alguna vez fue `ASESOR_PRINCIPAL` en `T_CONTACTO` (no depende de tener leads activos hoy) |
| `EstadoGestionItem` | id(String), nombre — parte [6] del SP, `DBO.[edu.TIP_ESTADO_GES]`. Estados de `cobranza/` (plano, sin padre — no confundir con `EstadoItem` de leads) |
| `MonedaItem` | id(String), codigo(String), nombre(String), simbolo(String) — parte [7] del SP, `SYSTABEXTER02 CODTABLA='MON'` (codargu ¦ deslarga ¦ descorta ¦ valor4). `id` = `codargu` (usado por `Comboable.fields[0]` y para autoseleccionar cuando el detalle de lead mande `idMoneda`); `codigo` = `valor4` (ISO: 'PEN'/'USD', para `NumberFormatUtils`) |
| `igvPorcentaje` | `double`, campo directo de `ListasGenericas` (no es lista) — parte [8] del SP, `SYSTABEXTER02 CODTABLA='IGV' codargu='01'`, valor único (ej. `18`) |
| `PaisItem` | id(String=codargu), nombre(String=deslarga), codigoTelefono(String=partidam) — parte [9] del SP, `SYSTABEXTER02 CODTABLA='CPA'`. Un solo catálogo sirve para el combo "País" (`id`+`nombre`) y para el selector de código telefónico (`codigoTelefono`+`nombre`, ej. "Perú (+51)") |
| `TipoDocumentoItem` | id(String=codargu), nombre(String=deslarga) — parte [10] del SP, `SYSTABEXTER02 CODTABLA='F01'`. `id` es **String**, no parsear con `toInt` |
| `ComprobanteItem` | id(String=codargu), nombre(String=deslarga) — parte [11] del SP, `SYSTABEXTER02 CODTABLA='DFA'` filtrado a Factura(01)/Boleta de venta(03)/Nota de crédito(07)/Nota de débito(08) |
| `NacionalidadItem` | id(String=codargu), nombre(String=deslarga), valor4(String) — parte [12] del SP, `SYSTABEXTER02 CODTABLA='NPA'`. Es el **gentilicio** ("PERUANO/A", "BRASILEÑO/A"...) — no confundir con `PaisItem` (nombre de lugar: "PERÚ", "BRASIL"...) |
| `ValoresCRMItem` | idCanalWsp(int), idPais(String), idNacionalidad(String), idEstadoNuevo(String), idEstadoGanado(String), idTipoBoleta(String), idTipoFactura(String), idTipoDocRuc(String), idTipoDocSnd(String), idTipoDocDni(String), idTipoDocCde(String), idTipoDocPas(String), idEstadoEnDesarrollo(String), idEstadoConPropuesta(String), idTipDocOtr(String), idTipDocSnr(String, "SIN RUC"/DOC.TRIB.NO.DOM.SIN.RUC, agregado 2026-08-19) — parte [13] del SP, **fila única** (sin `@sepRegistro`, no es lista). No implementa `Comboable`. `ValoresCRMItemModel` solo tiene `fromRawString` (sin `parseList`) |
| `SexoItem` | id(String), nombre(String) — parte [14] del SP, hardcodeado (`M`/`F`/`PD`) |
| `TipoParticipanteItem` | id(String), nombre(String), esInvitado(bool) — parte [15] del SP, hardcodeado (`1` Pagante · `2` Invitado · `3` Invitado auspicio · `4` Online). `esInvitado` = `true` en `2`/`3` (no paga) |
| `UbigeoItem` | dpto(String), prov(String), dis(String), nombre(String), `codigo` (getter = `dpto+prov+dis`) — parte [16] del SP, `DBO.SYSTABUBIGEO01`. Jerárquico: filtrar por `dpto` (departamento), `dpto`+`prov` (provincia), `codigo` completo identifica un distrito. Patrón ubigeo estándar para saber el nivel de una fila: `prov=='00' && dis=='00'` → departamento; `prov!='00' && dis=='00'` → provincia; `prov!='00' && dis!='00'` → distrito |
| `AreaItem` | id(String=codargu), nombre(String=deslarga) — parte [18] del SP, `SYSTABEXTER02 CODTABLA='AOF'`, agregada 2026-07-23. Área de empresa — usada en `lead/` (`EditContacto`, sección Empresa) **solo como sugerencia** del combo (`CustomComboSearchField(allowFreeText: true)`) — el valor guardado es texto libre (`T_EMPRESA_CONTACTO.NOM_AREA`), nunca el id, ver lead/CLAUDE.md |
| `CargoItem` | id(String=codCargo), nombre(String=desCargo) — parte [19] del SP, `DBO.SYSMCARGO01`, agregada 2026-07-23. Cargo de empresa — usada en `lead/` (`EditContacto`/`EditContactoSimple`) **solo como sugerencia**, mismo criterio que `AreaItem` (`NOM_CARGO`, texto libre). ⚠️ `T_EMPRESA_CONTACTO.ID_AREA`/`ID_CARGO` (columnas `INT`) existen pero están sin uso — no escribir ahí, la fuente de verdad es `NOM_AREA`/`NOM_CARGO` (VARCHAR) |
| `TipoCambioItem` | venta(double), compra(double) — parte [21] del SP, `DBO.SYSMTC01` filtrado a `FECHA = hoy`, agregada 2026-08-19. **Fila única, no implementa `Comboable`** (mismo criterio que `ValoresCRMItem`). Tipo de cambio del día USD→PEN — usado en `cobranza/` para convertir a soles un monto en dólares antes de aplicar la regla de detracción (con el tipo `venta`, nunca `compra`), ver `cobranza/CLAUDE.md`. **También disponible por separado, sin traer el catálogo completo** — `CatalogsRepository.getTipoCambio()` (`core/services/catalog_repository.dart`/`_impl.dart` → `CatalogsRemoteDatasource.getTipoCambio()`, task `'TC'` del mismo SP, `urlListasLst`) — usado en `cobranza/` al validar el plan de crédito, mismo criterio que el task `'NEG'` de `solicitudes/` (un task angosto en vez de recargar `CatalogsBloc` entero). Parte [20] (saludos de contacto, `PrefijoContactoItem`) no tiene entrada propia en esta tabla todavía — gap preexistente, no de esta sesión |

Todas implementan `Comboable` excepto `ValoresCRMItem`/`TipoCambioItem` (fila única, no son un ítem de lista/dropdown).
Parsear con `ListasGenericasModel.parse(rawResponse)`.
`AsesorItem` se usa en el picker de `lead/` (`LeadAsesorPickerModal`) y en `CobranzaAsesorPickerModal` —
el conteo por asesor NO viene del backend, se calcula en el cliente sobre los registros ya cargados.
`EstadoGestionItem` es solo de referencia/etiqueta — `cobranza/` traduce el `ID_ESTADO_GES` crudo a
sus 6 códigos internos (`PD`/`FP`/`F`/`CA`/`AN`/`PP`) con una tabla fija en `CobranzaModel`, no
consultando este catálogo en tiempo de ejecución (ver `cobranza/CLAUDE.md`).
`MonedaItem` alimenta el combo "Moneda" de `EditLeadFinancieraSection` (`lead/`) vía `CatalogsBloc.monedas` —
sin lista fija de respaldo; si el SP aún no devuelve la parte [7], el combo llega vacío y
`_monedaItem` queda `null` (ver `edit_lead_portrait.dart._inicializarCombos`).
`PaisItem`, `TipoDocumentoItem`, `ComprobanteItem`, `NacionalidadItem` e `igvPorcentaje` (partes
[8]-[12]) fueron agregados para reemplazar listas fijas hardcodeadas del wizard de
`solicitudes/` (Tipo documento, País, Comprobante, Nacionalidad, % IGV) — mientras el SP
real no las devuelva, llegan vacías/en 0 y hay que mantener un fallback local en la UI.
`ValoresCRMItem` (parte [13]) trae los IDs por defecto para preseleccionar combos sin
hardcodearlos en la UI (canal WhatsApp, país/nacionalidad Perú, estado nuevo/ganado, tipo de
boleta/factura, tipos de documento RUC/sin doc/DNI/CE/pasaporte) — mismos valores que las
variables `@ID_*` del SP `CSV_LISTAS_LST_APP`. Si el SP aún no devuelve la parte [13],
`valoresDefecto` llega con el `ValoresCRMItem()` const por defecto (todo en `0`/`''`).
`SexoItem` y `TipoParticipanteItem` (partes [14]-[15]) cubren los dos combos que
`solicitudes/CLAUDE.md` documentaba como "los únicos que pueden seguir hardcodeados" (Sexo del
paso 1, Tipo de participante del formulario de participante) — **ya conectados** desde
2026-07-15 (ver `solicitudes/CLAUDE.md` → "Catálogo real reemplaza ids hardcodeados"), las
listas fijas locales que tenían se eliminaron. La regla "saltar Facturación" usa `esInvitado`
(no compara `id == '2' || id == '3'`).
`UbigeoItem` (parte [16]) ya tiene selector en la UI desde el 2026-07-22 — paso 3 (Facturación)
de `solicitudes/`, 3 combos en cascada (Departamento/Provincia/Distrito) con
`CustomComboSearchField`, solo visibles con país Perú (ver `solicitudes/CLAUDE.md`, "Paso 3 —
Ubigeo nuevo..."). Ningún otro lugar de la app lo usa todavía.

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
2. `CleanResponseInterceptor` — deshace el JSON-string-literal que ASP.NET envuelve alrededor de la respuesta (comillas + escapes `\r`/`\n`/`\"`) — ver detalle abajo
3. `ErrorInterceptor` — convierte DioException en AppException
4. `LogInterceptor` — solo en debug mode

**`CleanResponseInterceptor` (`network/interceptors/clean_response_interceptor.dart`) — bug real de raíz (2026-08-20).**
El backend devuelve el resultado del SP como string C#, y el formatter JSON de ASP.NET lo envuelve
entre comillas y escapa saltos de línea/comillas internas (`\r`→`\r` literal, `\n`→`\n` literal,
`"`→`\"`) como cualquier JSON string — Dio nunca lo decodifica porque pedimos
`ResponseType.plain`. La versión vieja de este interceptor solo hacía
`replaceAll('"', '').trim()` — borraba comillas sueltas pero **no desescapaba nada**, así que
cualquier salto de línea real dentro del contenido (ej. la descripción multilínea de una
plantilla de WhatsApp) volvía como texto literal `"\n"`/`"\r"` visible en pantalla, y una comilla
real dentro del texto se borraba en silencio en vez de solo desescaparse. Esto se manifestó primero
como el bug de `\n` en `chat/` (parcheado a mano en `select_template_modal.dart._formatear()`, ver
`chat/CLAUDE.md`) y después como el mismo problema con `\r` en la lista de plantillas — **la causa
real nunca fue `chat/`, es este interceptor, y afecta a cualquier feature que reciba texto con
saltos de línea o comillas del backend**. Corregido usando `jsonDecode(raw)` (el body ya es un JSON
string literal válido) en vez de un replace manual — con fallback al comportamiento viejo solo si
el body no es JSON-string válido (no debería pasar nunca, red de seguridad). Los parches locales en
`chat/` (`_formatear()`) quedan como no-op inofensivo para datos ya corregidos, no hace falta
quitarlos.

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
| `NuevoLeadBotPayload` | `NUEVO_LEAD_BOT` | Lead nuevo creado por el bot — conversación puede no existir aún en la lista |

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
  final valoresDefecto = state.valoresDefecto;     // ValoresCRMItem — ids por defecto, no lista
  final sexos = state.sexos;                       // List<SexoItem>
  final tiposParticipante = state.tiposParticipante; // List<TipoParticipanteItem>
  final ubigeo = state.ubigeo;                     // List<UbigeoItem>
}
```

`CatalogsLoaded` expone un getter por cada campo de `ListasGenericas` (`catalog_item.dart`) —
si se agrega un campo nuevo ahí (parte nueva del SP `lstListas`), agregar también su getter acá
y sumarlo a `props` (usado por `Equatable`), si no el widget no podrá leerlo aunque el modelo
ya lo traiga parseado (pasó con `valoresDefecto`/`sexos`/`tiposParticipante`/`ubigeo`: el parseo
en `catalog_item_model.dart` ya existía, pero faltaban acá — nadie podía leerlos hasta el
2026-07-15, ver `solicitudes/CLAUDE.md` → "Catálogo real reemplaza ids hardcodeados").

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
Parámetros reales (todos opcionales, `null` = no cambia el valor actual):
`conversaciones` / `seguimientos` / `cobranza` / `solicitudes` (agregado 2026-08-14, ver
`home/CLAUDE.md` → "Badges del drawer/dashboard").
```dart
context.updateBadge(
  conversaciones: 3,
  cobranza: 0,
  solicitudes: 2,
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

// Nombre de archivo seguro para WhatsApp — solo A-Z a-z 0-9 . _ -
'PLANTAS-NUTRICIO´N.pdf'.sanitizarNombreArchivo  // 'PLANTAS-NUTRICION.pdf'

// Validador de email (para usar en validators de formularios)
null.emailValidator          // 'El email es requerido'
'abc@'.emailValidator        // 'Ingresa un email válido'
'abc@mail.com'.emailValidator // null (válido)
```

### ParseUtils — `utils/string/parse_utils.dart`

Parser genérico de campos separados por `¦`/`¬`/`¯` (ver `AppConstants.sepCampos/sepRegistros/
sepListas`) — usado por prácticamente todos los `*Model.fromRawString`/`fromFields` del proyecto.
`str`/`toInt`/`toDouble`/`toBool`/`toBoolNAC`/`toBoolINT` nunca lanzan excepción por índice fuera
de rango o valor no parseable — siempre caen a un default seguro (`''`/`0`/`0.0`/`false`).

**`toInt` (2026-08-12) — ahora acepta decimales como fallback.** Bug real encontrado en vivo:
`TipoDocumentoItem.canCaracteresMax` (`SYSTABEXTER02`, tabla genérica reusada por varios
catálogos con distinto significado por columna — ver `MonedaItem.valor4`/`PaisItem.
codigoTelefono`, mismo patrón) llega del SP como texto decimal (`"8.000"`, `"11.000"`...) aunque
el valor en sí sea un entero — `int.tryParse("8.000")` falla (un int no acepta punto decimal) y
caía en silencio al default `0`, sin ningún error visible. Efecto real: el límite de N°
documento (`DocumentoValidationUtils.maxLength`) quedaba en `0` → sin tope → el campo aceptaba
dígitos ilimitados, para CUALQUIER tipo de documento, en las 5 pantallas que usan ese utilitario
(paso 1/Facturación/Nuevo participante de `solicitudes/`, `EditContacto`/`EditContactoSimple`).
Corregido en la raíz, no campo por campo:
```dart
static int toInt(List<String> campos, int i) {
  final s = str(campos, i);
  return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
}
```
`int.tryParse` sigue siendo el camino rápido para un entero plano (`"8"` → `8`, sin cambio de
comportamiento) — el fallback a `double.tryParse(...).toInt()` solo entra si eso falla, cubriendo
cualquier columna genérica que el backend mande con decimales. Trunca hacia `0` (`"8.9"` → `8`),
no redondea — aceptable porque estos campos son conteos/ids/límites, nunca deberían traer una
fracción real. **Efecto retroactivo**: cualquier otro `ParseUtils.toInt(...)` del proyecto (hay
~90 usos, la mayoría ids reales de tablas de negocio — `T_LEAD`/`T_CONTACTO`/etc., poco
riesgo real) queda protegido igual sin tocarlos uno por uno — si alguno resultaba en `0` por este
mismo motivo, ahora se resuelve solo. `DocumentoValidationUtils.maxLength` también ganó un
fallback aparte (valores fijos DNI=8/RUC=11/CE=9/Pasaporte=12, por `ValoresCRMItem`) como red de
seguridad adicional si algún tipo puntual llegara sin el dato del catálogo — ver
`DocumentoValidationUtils` abajo.

### DocumentoValidationUtils — `utils/documento_validation_utils.dart`

Regla de longitud/teclado/formatters de un campo de N° documento según el tipo de documento
elegido — único lugar para esta regla, no reimplementarla por formulario.
**`maxLength` (2026-07-30) lee la longitud REAL del catálogo** —
`TipoDocumentoItem.canCaracteresMax` (parte [10] del SP `lstListas`, índice [4] del raw) — ya
no es un mapa fijo por id (`DNI=8`/`CE=12`/`RUC=11`/`Pasaporte=12`, hardcodeado a mano). Recibe
`List<TipoDocumentoItem>`, no `ValoresCRMItem`. `keyboardType`/`inputFormatters` (¿solo
dígitos?) siguen comparando contra los ids reales de `CatalogsBloc.valoresDefecto` (parte [13]
del SP, DNI/RUC), nunca hardcodear `'1'`/`'4'`/`'6'`/`'7'`.

```dart
final catalogState = context.watch<CatalogsBloc>().state;
final tiposDocumento = catalogState is CatalogsLoaded
    ? catalogState.tiposDocumento
    : const <TipoDocumentoItem>[];
final valoresDefecto = catalogState is CatalogsLoaded
    ? catalogState.valoresDefecto
    : const ValoresCRMItem();

CustomTextField(
  label: 'Número documento *',
  controller: ctrlNumDoc,
  keyboardType: DocumentoValidationUtils.keyboardType(tipoDocId, valoresDefecto),
  maxLength: DocumentoValidationUtils.maxLength(tipoDocId, tiposDocumento),
  inputFormatters: DocumentoValidationUtils.inputFormatters(tipoDocId, valoresDefecto),
)
```

Usado en `solicitudes/` — Datos del solicitante (paso 1), Facturación (paso 3, revirtió el
2026-07-30 un `maxLength: 12` fijo sin restricciones que tenía desde el 2026-07-22) y Nuevo
participante — y en `lead/EditContacto` (pantalla completa). Al cambiar el combo Tipo documento
en cualquiera de esos, limpiar el controller de N° documento (`ctrl.clear()`) — el texto ya
tipeado puede no calzar con la nueva longitud/formato (ej. letras de Pasaporte al cambiar a DNI)
y Flutter no lo trunca/filtra retroactivamente. **`EditContactoSimplePortrait`** (`lead/`,
pantalla reducida) ya usa este utilitario desde el 2026-08-12 (ver `lead/CLAUDE.md` →
"`DocumentoValidationUtils` agregado a Número documento") — antes su campo Número documento
tenía teclado numérico fijo y sin `maxLength`, gap que quedó cerrado.

**`limitarLongitud` (2026-08-12)** — nuevo, complementa a `maxLength`. `maxLength` del widget
(`TextField`/`CustomTextField`) solo limita lo que el usuario **tipea** (vía
`LengthLimitingTextInputFormatter`, que solo intercepta ediciones reales desde el teclado) — un
valor asignado directo a `TextEditingController.text = valor` (prellenado desde backend,
negociación, o el resultado de una búsqueda por documento) **no pasa por ese formatter**, así que
Flutter no lo trunca solo. Encontrado en vivo en `solicitudes/` (`solicitudes/CLAUDE.md` →
"Refactor — 'Generar solicitud'..."): un contacto con un N° documento de 17 dígitos guardado sin
validación (dato sucio, probablemente originado en `EditContactoSimplePortrait`, ver arriba) se
mostraba completo en "Datos del solicitante" pese a que Tipo documento era DNI (máximo 8).
```dart
final numDocSeguro = DocumentoValidationUtils.limitarLongitud(tipoDocId, numDoc, tiposDocumento);
```
Trunca (no valida/no avisa) al máximo real del tipo resuelto — usar en cualquier punto donde un
N° documento se asigne por código (no por tipeo del usuario) antes de que llegue al controller o
al modelo que lo acompaña (`DatosSolicitante`/`DatosFacturacion`/`ParticipanteLocal`). **Ojo con
la consistencia**: si el valor también viaja a un modelo usado para comparar `huboCambios`
(`solicitudSinCambiosPendientes`), truncar solo el controller y no el modelo (o viceversa) genera
un falso positivo de "hay cambios sin guardar" apenas se carga la pantalla — truncar siempre en
el punto de origen (antes de construir el modelo Y de asignar el controller), nunca en dos
lugares por separado. Aplicado en `solicitud_completar_view_carga.dart` (Datos del solicitante al
crear desde negociación y al editar, Facturación al editar, N° documento de cada participante al
cargar una solicitud existente) — no en Nuevo participante ni Facturación al TIPEAR (ahí el
usuario ya está limitado por `inputFormatters`, sin necesidad de truncar nada por código).

### LauncherUtils — `utils/launcher/launcher_utils.dart`

```dart
await LauncherUtils.abrirTelefono('999888777');
await LauncherUtils.abrirCorreo(
  'cliente@mail.com',
  asunto: 'Propuesta GS1',
  cuerpo: 'Estimado...',
)
```