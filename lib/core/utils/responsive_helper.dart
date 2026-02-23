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

  // ============================================================
  // IMÁGENES RESPONSIVAS
  // ============================================================

  /// Tamaño nativo de referencia para imágenes landscape
  static const double _nativeImageWidth = 1900.0;
  static const double _nativeImageHeight = 1200.0;
  static const double _nativeAspectRatio =
      _nativeImageWidth / _nativeImageHeight; // ~1.583

  /// Calcula el ancho real que debe tener una imagen dado el espacio disponible.
  ///
  /// - Si el espacio disponible es mayor o igual al tamaño nativo → usa el nativo.
  /// - Si el espacio es menor → se achica manteniendo el aspect ratio.
  ///
  /// [availableWidth]: ancho del contenedor donde vive la imagen.
  /// [nativeWidth]: ancho nativo de la imagen (default 1900).
  /// [maxWidthFraction]: fracción máxima del espacio disponible a usar (0.0 - 1.0, default 1.0).
  static double imageWidth(
    double availableWidth, {
    double nativeWidth = _nativeImageWidth,
    double maxWidthFraction = 1.0,
  }) {
    final maxAllowed = availableWidth * maxWidthFraction;
    return maxAllowed < nativeWidth ? maxAllowed : nativeWidth;
  }

  /// Calcula el alto proporcional dado un ancho calculado con [imageWidth].
  ///
  /// [width]: ancho resultante (usar el valor de [imageWidth]).
  /// [aspectRatio]: relación ancho/alto (default 1900/1200 ≈ 1.583).
  static double imageHeight(
    double width, {
    double aspectRatio = _nativeAspectRatio,
  }) {
    return width / aspectRatio;
  }

  /// Devuelve un [Size] con ancho y alto responsivos para una imagen.
  ///
  /// Ejemplo:
  /// ```dart
  /// final size = ResponsiveHelper.imageSize(context);
  /// Image.asset('img.png', width: size.width, height: size.height);
  /// ```
  static Size imageSize(
    BuildContext context, {
    double nativeWidth = _nativeImageWidth,
    double nativeHeight = _nativeImageHeight,
    double maxWidthFraction = 1.0,
  }) {
    final availableWidth = getWidth(context);
    final aspectRatio = nativeWidth / nativeHeight;
    final w = imageWidth(
      availableWidth,
      nativeWidth: nativeWidth,
      maxWidthFraction: maxWidthFraction,
    );
    final h = imageHeight(w, aspectRatio: aspectRatio);
    return Size(w, h);
  }

  /// Versión que usa el ancho de un LayoutBuilder (más precisa dentro de columnas/cards).
  ///
  /// Ejemplo dentro de un LayoutBuilder:
  /// ```dart
  /// LayoutBuilder(builder: (context, constraints) {
  ///   final size = ResponsiveHelper.imageSizeFromConstraints(constraints);
  ///   return Image.asset('img.png', width: size.width, height: size.height);
  /// });
  /// ```
  static Size imageSizeFromConstraints(
    BoxConstraints constraints, {
    double nativeWidth = _nativeImageWidth,
    double nativeHeight = _nativeImageHeight,
    double maxWidthFraction = 1.0,
  }) {
    final availableWidth = constraints.maxWidth.isInfinite
        ? nativeWidth
        : constraints.maxWidth;
    final aspectRatio = nativeWidth / nativeHeight;
    final w = imageWidth(
      availableWidth * maxWidthFraction,
      nativeWidth: nativeWidth,
    );
    final h = imageHeight(w, aspectRatio: aspectRatio);
    return Size(w, h);
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

// ============================================================

/// Widget de imagen responsiva.
///
/// Muestra la imagen a su tamaño nativo (1900x1200 por defecto) si hay espacio,
/// y se achica proporcionalmente cuando el espacio disponible es menor.
///
/// USOS:
///
/// 1. Con asset:
/// ```dart
/// ResponsiveImage.asset('assets/banner.png')
/// ```
///
/// 2. Con network:
/// ```dart
/// ResponsiveImage.network('https://example.com/banner.jpg')
/// ```
///
/// 3. Con tamaño nativo personalizado:
/// ```dart
/// ResponsiveImage.asset(
///   'assets/foto.jpg',
///   nativeWidth: 800,
///   nativeHeight: 600,
/// )
/// ```
///
/// 4. Con fracción máxima (ej: ocupar máximo el 80% del ancho disponible):
/// ```dart
/// ResponsiveImage.asset(
///   'assets/banner.png',
///   maxWidthFraction: 0.8,
/// )
/// ```
class ResponsiveImage extends StatelessWidget {
  final String source;
  final _ImageSourceType _sourceType;

  final double nativeWidth;
  final double nativeHeight;
  final double maxWidthFraction;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ResponsiveImage._({
    super.key,
    required this.source,
    required _ImageSourceType sourceType,
    this.nativeWidth = 1900.0,
    this.nativeHeight = 1200.0,
    this.maxWidthFraction = 1.0,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : _sourceType = sourceType;

  /// Imagen desde assets.
  factory ResponsiveImage.asset(
    String assetPath, {
    Key? key,
    double nativeWidth = 1900.0,
    double nativeHeight = 1200.0,
    double maxWidthFraction = 1.0,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    return ResponsiveImage._(
      key: key,
      source: assetPath,
      sourceType: _ImageSourceType.asset,
      nativeWidth: nativeWidth,
      nativeHeight: nativeHeight,
      maxWidthFraction: maxWidthFraction,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      borderRadius: borderRadius,
    );
  }

  /// Imagen desde URL de red.
  factory ResponsiveImage.network(
    String url, {
    Key? key,
    double nativeWidth = 1900.0,
    double nativeHeight = 1200.0,
    double maxWidthFraction = 1.0,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    return ResponsiveImage._(
      key: key,
      source: url,
      sourceType: _ImageSourceType.network,
      nativeWidth: nativeWidth,
      nativeHeight: nativeHeight,
      maxWidthFraction: maxWidthFraction,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ResponsiveHelper.imageSizeFromConstraints(
          constraints,
          nativeWidth: nativeWidth,
          nativeHeight: nativeHeight,
          maxWidthFraction: maxWidthFraction,
        );

        Widget image;

        if (_sourceType == _ImageSourceType.asset) {
          image = Image.asset(
            source,
            width: size.width,
            height: size.height,
            fit: fit,
            errorBuilder: errorWidget != null
                ? (_, _, _) => SizedBox(
                    width: size.width,
                    height: size.height,
                    child: errorWidget,
                  )
                : null,
          );
        } else {
          image = Image.network(
            source,
            width: size.width,
            height: size.height,
            fit: fit,
            loadingBuilder: placeholder != null
                ? (_, child, loadingProgress) => loadingProgress == null
                      ? child
                      : SizedBox(
                          width: size.width,
                          height: size.height,
                          child: placeholder,
                        )
                : null,
            errorBuilder: errorWidget != null
                ? (_, _, _) => SizedBox(
                    width: size.width,
                    height: size.height,
                    child: errorWidget,
                  )
                : null,
          );
        }

        if (borderRadius != null) {
          image = ClipRRect(borderRadius: borderRadius!, child: image);
        }

        return image;
      },
    );
  }
}

enum _ImageSourceType { asset, network }
