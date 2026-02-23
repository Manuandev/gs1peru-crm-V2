// lib\core\constants\app_images.dart

import 'package:flutter/material.dart';

/// Imagenes usadas en el proyecto
///
/// PROPÓSITO:
/// - Llamar a la imagen mas facil y rapido
/// - No harcodear ninguna direccion, asi es mas controlado
///
/// USO:
/// Image.asset(
///   logoGs1Peru,
///   width: logoSize,
///   height: logoSize,
/// ),
/// SizedBox(
///   width: logoSize,
///   height: logoSize,
///   child: 
///     SvgPicture.asset(
///       AppImages.logoTheme(context),
///       fit: BoxFit.contain,
///     ),
/// ),
class AppImages {
  AppImages._();

  // ── Logos estáticos ────────────────────────────────────────────────────────
  static const String logoGs1Peru = 'assets/images/logo_gs1.svg';
  static const String logoGs1PeruBlanco = 'assets/images/logo_gs1_blanco.svg';
  static const String logoGoogle = 'assets/icons/google_logo.svg';

  // ── Logo dependiente del tema ──────────────────────────────────────────────
  /// Devuelve el logo correcto según el brillo del tema actual.
  /// Uso: AppImages.logoTheme(context)
  static String logoTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoGs1PeruBlanco : logoGs1Peru;
  }

  // Sin contexto, útil en ViewModels o tests
  static String logoFromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? logoGs1PeruBlanco : logoGs1Peru;
  }
}
