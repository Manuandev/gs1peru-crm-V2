// lib/core/utils/responsive_helper.dart

import 'package:flutter/material.dart';

// Constantes
import 'package:app_crm/core/constants/app_breakpoints.dart';

/// Helper para Responsive Design
///
/// PROPÓSITO:
/// - Facilitar la creación de UIs responsivas
/// - Helpers para detectar tamaño de pantalla
/// - Valores responsivos automáticos
///
/// USO:
/// final isMobile = ResponsiveHelper.isMobile(context);
/// final padding = ResponsiveHelper.screenPadding(context);
class ResponsiveHelper {
  // Prevenir instanciación
  ResponsiveHelper._();

  // ============================================================
  // OBTENER DIMENSIONES
  // ============================================================

  /// Obtener ancho de pantalla
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtener alto de pantalla
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // ============================================================
  // DETECTAR TIPO DE DISPOSITIVO
  // ============================================================

  /// ¿Es móvil? (< 600px)
  static bool isMobile(BuildContext context) {
    return getWidth(context) < AppBreakpoints.mobile;
  }

  /// ¿Es tablet? (600px - 900px)
  static bool isTablet(BuildContext context) {
    final width = getWidth(context);
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  /// ¿Es desktop? (> 900px)
  static bool isDesktop(BuildContext context) {
    return getWidth(context) >= AppBreakpoints.tablet;
  }

  /// ¿Es desktop grande? (> 1200px)
  static bool isDesktopLarge(BuildContext context) {
    return getWidth(context) >= AppBreakpoints.desktop;
  }

  // ============================================================
  // PADDING RESPONSIVO
  // ============================================================

  /// Padding horizontal de pantalla (responsivo)
  /// - Móvil: 16px
  /// - Tablet: 24px
  /// - Desktop: 32px
  static double screenPaddingHorizontal(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  /// Padding completo de pantalla (responsivo)
  static EdgeInsets screenPadding(BuildContext context) {
    final horizontal = screenPaddingHorizontal(context);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16.0);
  }

  // ============================================================
  // NÚMERO DE COLUMNAS (para grids)
  // ============================================================

  /// Obtener número de columnas según tamaño
  /// - Móvil: 1 columna
  /// - Tablet: 2 columnas
  /// - Desktop: 3-4 columnas
  static int getGridColumns(BuildContext context, {int? maxColumns}) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return maxColumns ?? 4;
  }

  // ============================================================
  // TAMAÑO DE TEXTO RESPONSIVO
  // ============================================================

  /// Obtener tamaño de texto responsivo
  /// baseFontSize se multiplica según dispositivo
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  // ============================================================
  // ANCHO MÁXIMO PARA CONTENIDO
  // ============================================================

  /// Obtener ancho máximo para centrar contenido
  /// Útil para formularios y contenido de lectura
  static double maxContentWidth(BuildContext context) {
    final width = getWidth(context);
    if (width < 600) return width; // Móvil: ancho completo
    if (width < 900) return 600.0; // Tablet: max 600px
    return 800.0; // Desktop: max 800px
  }

  // ============================================================
  // OBTENER VALOR SEGÚN DISPOSITIVO
  // ============================================================

  /// Obtener valor diferente según tamaño
  ///
  /// Ejemplo:
  /// final columns = ResponsiveHelper.getValue(
  ///   context,
  ///   mobile: 1,
  ///   tablet: 2,
  ///   desktop: 4,
  /// );
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

// ============================================================

/// Widget Builder Responsivo
///
/// PROPÓSITO:
/// - Construir widgets diferentes según tamaño
/// - Alternativa más limpia a if/else
///
/// USO:
/// ResponsiveBuilder(
///   mobile: (context) => MobileWidget(),
///   tablet: (context) => TabletWidget(),
///   desktop: (context) => DesktopWidget(),
/// )
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return desktop?.call(context) ?? tablet?.call(context) ?? mobile(context);
    }

    if (ResponsiveHelper.isTablet(context)) {
      return tablet?.call(context) ?? mobile(context);
    }

    return mobile(context);
  }
}
