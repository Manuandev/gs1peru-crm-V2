// lib/core/constants/app_spacing.dart

/// Espaciado del Sistema de Diseño
///
/// PROPÓSITO:
/// - Valores de espacio consistentes en toda la app
/// - Escala basada en múltiplos de 4px (estándar Material Design)
/// - Un único lugar para ajustar el ritmo visual de la aplicación
///
/// REGLA DE ORO:
/// Nunca uses números sueltos para spacing. Siempre usa estas constantes.
/// Si necesitas un valor intermedio, agrégalo aquí con su documentación.
///
/// USO:
/// ```dart
/// SizedBox(height: AppSpacing.md)
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))
/// EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding)
/// ```
///
/// ESCALA:
/// xxs(2) → xs(4) → sm(8) → md(16) → lg(24) → xl(32) → xxl(48) → xxxl(64)
class AppSpacing {
  // Prevenir instanciación
  AppSpacing._();

  // ============================================================
  // ESPACIADO BASE (múltiplos de 4 y 8)
  // ============================================================

  /// Micro espaciado: 2px
  /// Uso: Padding mínimo en badges, separadores internos muy pequeños
  static const double xxs = 2.0;

  /// Extra pequeño: 4px
  /// Uso: Espacio entre ícono y texto dentro de un mismo elemento
  static const double xs = 4.0;

  /// Pequeño: 8px
  /// Uso: Espacio interno de botones, gap entre elementos relacionados
  static const double sm = 8.0;

  /// Pequeño: 12px
  /// Uso: Espacio interno entre elementos relacionados
  static const double sm2 = 12.0;

  /// Medio: 16px (BASE)
  /// Uso: Padding estándar de contenedores, separación entre inputs
  static const double md = 16.0;

  /// Grande: 24px
  /// Uso: Separación entre secciones de una misma pantalla
  static const double lg = 24.0;

  /// Extra grande: 32px
  /// Uso: Separación entre bloques principales, padding de card de login
  static const double xl = 32.0;

  /// Extra extra grande: 48px
  /// Uso: Separación máxima (ej: entre logo e inputs en Splash)
  static const double xxl = 48.0;

  /// Extra extra extra grande: 64px
  /// Uso: Espacios especiales (ej: antes del indicador de carga en Splash)
  static const double xxxl = 64.0;

  // ============================================================
  // ESPACIADO SEMÁNTICO (atajos con nombre descriptivo)
  // ============================================================

  /// Padding estándar para pantallas (horizontal y vertical)
  /// - Corresponde a 16px (md)
  static const double screenPadding = md;

  /// Padding para el contenido interno de tarjetas (Card)
  /// - Corresponde a 16px (md)
  static const double cardPadding = md;

  /// Padding horizontal de botones
  /// - Corresponde a 32px (xl) — genera botones con buen ancho visual
  static const double buttonPaddingHorizontal = xl;

  /// Padding vertical de botones
  /// - Corresponde a 16px (md) — asegura altura mínima táctil
  static const double buttonPaddingVertical = md;

  /// Espaciado entre campos de un formulario
  /// - Corresponde a 16px (md)
  static const double formSpacing = md;

  /// Espaciado entre secciones grandes de una pantalla
  /// - Corresponde a 32px (xl)
  static const double sectionSpacing = xl;

  // ============================================================
  // VALORES INTERMEDIOS
  // Para valores entre los puntos de escala base. Agrega solo
  // si el valor aparece en múltiples componentes.
  // ============================================================

  /// 3px — padding interno de badges compactos (ej: badge de notificaciones en AppBar)
  static const double badgePadding = 3.0;

  /// 3px — padding vertical del chip _Tag en tiles de notificación (campaña, canal, evento)
  static const double tagPaddingV = 3.0;

  /// 7px — padding horizontal del badge de conteo en CollapsibleSection
  static const double badgePaddingH = 7.0;

  /// 6px — espaciado entre chips/tags en Wrap (spacing y runSpacing)
  static const double chipGap = 6.0;

  /// 14px — padding horizontal del chip de filtro en listas (LeadListFilterChips)
  static const double chipPaddingH = 14.0;

  /// 9px — padding vertical del chip de filtro en listas (LeadListFilterChips)
  static const double chipPaddingV = 9.0;

  /// 80px — padding superior para pantallas de estado vacío (empty state)
  static const double emptyStateTop = 80.0;

  /// 12px — gap entre ícono y texto en notificaciones; margen
  /// externo lateral de snackbars
  static const double snackGap = 12.0;

  /// 14px — padding interno cómodo en notificaciones
  /// (izquierda, top, bottom del cuerpo del snackbar)
  static const double snackPadding = 14.0;

  /// 10px — padding derecho del cuerpo de snackbars
  /// (deja espacio visual al botón de cierre)
  static const double snackPaddingEnd = 10.0;
}
