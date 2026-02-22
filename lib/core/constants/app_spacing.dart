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
}
