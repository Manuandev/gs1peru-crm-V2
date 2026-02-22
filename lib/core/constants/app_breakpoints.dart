// lib/core/constants/app_breakpoints.dart

/// Breakpoints para Responsive Design
///
/// PROPÓSITO:
/// - Definir los puntos donde el layout cambia según el ancho de pantalla
/// - Consistente en toda la app (usado por ResponsiveHelper)
///
/// USO:
/// ```dart
/// if (width < AppBreakpoints.mobile) { /* layout móvil */ }
/// ```
///
/// ESCALA:
/// - mobile    → < 600px   (smartphones)
/// - tablet    → 600–900px (tablets pequeñas)
/// - desktop   → 900–1200px (tablets grandes / laptops)
/// - desktopLarge → > 1200px (monitores)
class AppBreakpoints {
  // Prevenir instanciación
  AppBreakpoints._();

  // ============================================================
  // BREAKPOINTS PRINCIPALES
  // ============================================================

  /// Móvil: Hasta 600px
  static const double mobile = 600;

  /// Tablet: De 600px a 900px
  static const double tablet = 900;

  /// Desktop: Mayor a 900px
  static const double desktop = 1200;

  /// Desktop grande: Mayor a 1200px
  static const double desktopLarge = 1600;
}

// ============================================================

/// Tamaños del Sistema de Diseño
///
/// PROPÓSITO:
/// - Tamaños consistentes para iconos, botones, bordes y elevaciones
/// - Cambiar un valor aquí afecta toda la app automáticamente
/// - Complementa a AppSpacing (que maneja separaciones entre elementos)
///
/// SECCIONES:
/// - radiusXs … radiusCircular → redondeo de bordes
/// - elevationNone … elevationHigh → sombras
/// - iconSm … iconDisplay → tamaños de íconos
/// - inputHeight, buttonHeight… → alturas de controles
/// - maxWidthForm … maxWidthWide → anchos máximos para centrar contenido
///
/// USO:
/// ```dart
/// Icon(AppIcons.user, size: AppSizing.iconMd)
/// BorderRadius.circular(AppSizing.radiusMd)
/// SizedBox(height: AppSizing.buttonHeight)
/// ```
class AppSizing {
  // Prevenir instanciación
  AppSizing._();

  // ============================================================
  // BORDER RADIUS (Redondeo de bordes)
  // ============================================================

  /// Muy pequeño: 4px — chips, badges, skeletons
  static const double radiusXs = 4.0;

  /// Pequeño: 8px — snackbars, tooltips
  static const double radiusSm = 8.0;

  /// Medio: 12px (BASE) — inputs, botones, tarjetas internas
  static const double radiusMd = 12.0;

  /// Grande: 16px — cards principales, dialogs
  static const double radiusLg = 16.0;

  /// Extra grande: 24px — bottom sheets, cards hero
  static const double radiusXl = 24.0;

  /// Circular: 999px — avatares, FABs, chips pill
  static const double radiusCircular = 999.0;

  // ============================================================
  // ELEVACIÓN (Sombras)
  // ============================================================

  /// Sin elevación — elementos planos (AppBar sin sombra)
  static const double elevationNone = 0.0;

  /// Elevación baja: 2dp — cards en reposo
  static const double elevationLow = 2.0;

  /// Elevación media: 4dp — botones primarios, FAB
  static const double elevationMedium = 4.0;

  /// Elevación alta: 8dp — dialogs, bottom sheets, login card
  static const double elevationHigh = 8.0;

  // ============================================================
  // TAMAÑOS DE ICONOS
  // ============================================================

  /// Ícono pequeño: 16px — iconos dentro de labels o chips
  static const double iconSm = 16.0;

  /// Ícono medio: 24px (BASE) — ícono estándar de Material Design
  static const double iconMd = 24.0;

  /// Ícono de navegación: 22px — ítems del drawer
  /// Ligeramente más pequeño que iconMd para equilibrio visual en listas.
  static const double iconNav = 22.0;

  /// Ícono grande: 32px — iconos en headers y estados vacíos
  static const double iconLg = 32.0;

  /// Ícono extra grande: 48px — ilustraciones de error/éxito en pantalla
  static const double iconXl = 48.0;

  /// Ícono muy grande: 80px — logo/lock en formularios de login
  static const double iconXxl = 80.0;

  /// Ícono display: 120px — logo principal del Splash
  static const double iconDisplay = 120.0;

  // ============================================================
  // ALTURAS DE ELEMENTOS
  // ============================================================

  /// Altura de input: 56px
  static const double inputHeight = 56.0;

  /// Altura de botón: 48px (BASE)
  static const double buttonHeight = 48.0;

  /// Altura de botón pequeño: 36px
  static const double buttonHeightSmall = 36.0;

  /// Altura de botón grande: 56px
  static const double buttonHeightLarge = 56.0;

  /// Altura de AppBar: 56px (kToolbarHeight)
  static const double appBarHeight = 56.0;

  // ============================================================
  // ANCHOS MÁXIMOS (para centrar contenido)
  // ============================================================

  /// Ancho máximo para formularios: 400px
  /// Ejemplo: login, registro, cambio de contraseña
  static const double maxWidthForm = 400.0;

  /// Ancho máximo para contenido: 600px
  /// Ejemplo: artículos, descripción de producto
  static const double maxWidthContent = 600.0;

  /// Ancho máximo para contenido ancho: 1200px
  /// Ejemplo: dashboards, tablas de datos
  static const double maxWidthWide = 1200.0;

  // ============================================================
  // SPINNERS
  // ============================================================

  /// Grosor spinner pequeño
  static const double spinnerStrokeSmall = 2.0;

  /// Grosor spinner normal (BASE)
  static const double spinnerStrokeMedium = 3.0;

  /// Grosor spinner grande
  static const double spinnerStrokeLarge = 4.0;
}
