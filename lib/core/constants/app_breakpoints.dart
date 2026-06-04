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

  /// Altura máxima considerada "compacta" (landscape en móvil): 500dp
  /// Usado en _DrawerHeader para detectar orientación landscape con pantalla pequeña
  static const double compactHeight = 500;
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

  /// Chip/tag: 6px — _Tag de campaña / canal / evento en tiles de notificación
  static const double radiusTag = 6.0;

  /// Pequeño: 8px — snackbars, tooltips
  static const double radiusSm = 8.0;

  /// Pequeño-medio: 10px — badge de conteo en CollapsibleSection
  static const double radiusSm2 = 10.0;

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

  /// Ícono pequeño en botones de acción: 18px
  static const double iconActionSm = 18.0;

  /// Ícono medio: 24px (BASE) — ícono estándar de Material Design
  static const double iconMd = 24.0;

  /// Ícono de navegación: 22px — ítems del drawer
  /// Ligeramente más pequeño que iconMd para equilibrio visual en listas.
  static const double iconNav = 22.0;

  /// Ícono grande: 32px — iconos en headers y estados vacíos
  static const double iconLg = 32.0;

  /// FaIcon grande: 28px — FontAwesome en DashboardCard (FA es visualmente mayor que Material, se reduce 4px)
  static const double iconFaLg = 28.0;

  /// Ícono extra grande: 48px — ilustraciones de error/éxito en pantalla
  static const double iconXl = 48.0;

  /// Ícono muy grande: 80px — logo/lock en formularios de login
  static const double iconXxl = 80.0;

  /// Ícono display: 120px — logo principal del Splash
  static const double iconDisplay = 120.0;

  // ============================================================
  // LOGO — Pantalla de Login
  // ============================================================

  /// Factor de escala del logo en login: 0.35 (35% del lado más corto)
  /// Permite que el logo escale con el tamaño de pantalla — LoginLayout._LogoSection
  static const double logoLoginRatio = 0.35;

  /// Tamaño máximo del logo en login: 160px
  /// Límite superior del clamp — evita logos demasiado grandes en tablets
  static const double logoLoginMax = 160.0;

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

  // Avatares
  static const double avatarSm = 42;
  static const double avatarMd = 48;
  static const double avatarLg = 56;
  static const double avatarXl = 72;

  // Radio (para CircleAvatar que usa radius, no size)
  static const double avatarRadiusSm = avatarSm / 2; // 21
  static const double avatarRadiusMd = avatarMd / 2; // 24
  static const double avatarRadiusLg = avatarLg / 2; // 28
  static const double avatarRadiusXl = avatarXl / 2; // 36

  /// Radio del avatar en PrioridadTileHome: 25px (avatarRadiusSm + 4, equilibrio visual con el tile)
  static const double avatarRadiusHomeTile = 25.0;

  /// Botón de acción compacto en tiles: 32px (chat, llamar en PrioridadTile)
  static const double miniActionButton = 32.0;

  /// Diámetro del badge de notificaciones en AppBar — 18px
  /// Más pequeño que mensajesBadgeSize (22px): el AppBar tiene menos espacio visual
  static const double notifBadgeSize = 18.0;

  // Badge de canal sobre el avatar del lead (LeadCard)
  /// Diámetro del badge circular que muestra el ícono del canal sobre el avatar — 18px
  static const double avatarCanalBadge = 18.0;
  /// Grosor del borde blanco del badge de canal — 1.5px
  static const double canalBadgeBorder = 1.5;
  /// Ícono dentro del badge de canal (encima del avatar) — 10px
  static const double iconCanalBadge = 10.0;
  /// Ícono del canal en la línea de nombre del lead — 12px
  static const double iconCanalInfo = 12.0;
  /// Diámetro del badge de mensajes no leídos (LeadCard, borde derecho) — 22px
  static const double mensajesBadgeSize = 22.0;

  // ============================================================
  // VALORES ADICIONALES
  // ============================================================

  /// Hairline / línea mínima: 1dp — Divider sin padding extra, bordes finos
  static const double hairline = 1.0;

  /// Ícono micro: 13dp — metadatos en tiles (teléfono, persona, acción, aviso)
  static const double iconXxs = 13.0;

  /// Ícono extra pequeño: 14dp — deleteIcon en Chip, íconos inline en texto
  static const double iconXs = 14.0;

  /// Ícono en campo de búsqueda: 20dp — prefixIcon en TextField de búsqueda
  static const double iconSearch = 20.0;

  /// Contenedor cuadrado del ícono en snackbar/toast: 36dp
  static const double snackIconContainer = 36.0;

  /// Elevación mínima: 1dp — botón secundario en reposo
  static const double elevationMin = 1.0;

  /// Altura de la barra de progreso en snackbar/toast: 3dp
  static const double snackProgressBar = 3.0;

  /// Altura del contenido del diálogo de selección múltiple con búsqueda: 420dp
  static const double searchDialogContent = 420.0;

  // ============================================================
  // SPLASH — Indicador de carga (dots)
  // ============================================================

  /// Diámetro de cada punto en el indicador de carga del Splash: 8dp
  static const double splashDotSize = 8.0;

  // ============================================================
  // ANIMACIÓN — UnderConstructionPage (anillos giratorios)
  // ============================================================

  /// Anillo exterior + SizedBox contenedor: 260dp
  static const double animRingOuter = 260.0;

  /// Anillo medio: 210dp
  static const double animRingMid = 210.0;

  /// Anillo interior: 160dp
  static const double animRingInner = 160.0;

  /// Contenedor central con logo: 110dp
  static const double animRingCenter = 110.0;

  /// Logo SVG dentro del contenedor central: 72dp
  static const double animLogoSize = 72.0;

  /// Grosor del trazo de cada anillo animado: 1.5dp
  static const double animRingStroke = 1.5;

  // ============================================================
  // ÍCONOS DE ESTADO VACÍO / ERROR (responsive)
  // ============================================================

  /// Ícono de error en móvil: 64dp
  static const double iconErrorSm = 64.0;

  /// Ícono de error en tablet: 72dp
  static const double iconErrorMd = 72.0;

  // ============================================================
  // SNACKBAR / TOAST
  // ============================================================

  /// Offset inferior para posicionar el snackbar arriba: 120dp
  /// Uso: MediaQuery.size.height - AppSizing.snackTopOffset
  static const double snackTopOffset = 120.0;

  // ============================================================
  // BORDES DE FOCO / ACTIVO
  // ============================================================

  /// Ancho del borde en estado focus o seleccionado: 2dp
  /// Usado en inputs enfocados, botones outlined, etc.
  static const double borderFocusWidth = 2.0;

  // ============================================================
  // DRAWER HEADER — Avatar responsive
  // ============================================================

  /// Radio del avatar en drawer (modo landscape compacto): 20dp
  static const double drawerAvatarRadiusCompact = 20.0;

  /// Radio del avatar en drawer (orientación normal): 30dp
  static const double drawerAvatarRadius = 30.0;
}
