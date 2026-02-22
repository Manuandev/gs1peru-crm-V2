// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Colores del Sistema de Diseño
///
/// PROPÓSITO:
/// - Colores consistentes en toda la app
/// - Fácil cambiar tema completo
/// - Un solo lugar para colores
///
/// USO:
/// Text('Hola', style: TextStyle(color: AppColors.primary))
class AppColors {
  // Prevenir instanciación
  AppColors._();

  // ============================================================
  // COLORES PRINCIPALES (GS1)
  // ============================================================

  /// Color principal de la marca - Azul corporativo GS1
  static const Color primary = Color(0xFF005DAA);

  /// Color secundario - Naranja corporativo GS1
  static const Color secondary = Color(0xFFF58220);

  /// Color de acento si lo crees necesario
  //static const Color accent = Color(0xFFF58220);

  // ============================================================
  // COLORES DE ESTADO
  // ============================================================

  /// Color para éxitos
  static const Color success = Color(0xFF4CAF50); // Verde

  /// Color para errores
  static const Color error = Color(0xFFF44336); // Rojo

  /// Color para advertencias
  static const Color warning = Color(0xFFFF9800); // Naranja

  /// Color para información
  static const Color info = Color(0xFF2196F3); // Azul

  // ============================================================
  // COLORES DE FONDO
  // ============================================================


  /// Fondo principal de la app (para modo claro)
  static const Color background = Color(0xFFF8F9FB);

  /// Fondo principal de la app (para modo oscuro)
  static const Color backgroundDark = Color(0xFF121212);

  /// Fondo de tarjetas y superficies
  static const Color surface = Color(0xFFFFFFFF); // Blanco


  // ============================================================
  // COLORES DE TEXTO
  // ============================================================

  /// Texto principal
  static const Color textPrimary = Color(0xFF1A1A1A); // Negro

  /// Texto secundario (menos importante)
  static const Color textSecondary = Color(0xFF757575); // Gris

  /// Texto deshabilitado
  static const Color textDisabled = Color(0xFFBDBDBD); // Gris claro

  /// Texto en fondos oscuros
  static const Color textOnDark = Color(0xFFFFFFFF); // Blanco

  // ============================================================
  // COLORES DE BORDES
  // ============================================================

  /// Borde normal
  static const Color border = Color(0xFFE0E0E0); // Gris muy claro

  /// Borde cuando está enfocado (puedes poner el que quieras - traes primary ya que se es parecido)
  //static const Color borderFocused = Color(0xFF2196F3); // Azul
  static const Color borderFocused = primary;

  /// Borde de error
  static const Color borderError = Color(0xFFF44336); // Rojo

  // ============================================================
  // COLORES NEUTRALES (Grises)
  // ============================================================

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============================================================
  // COLORES CON OPACIDAD
  // ============================================================

  /// Negro con opacidad (para overlays)
  static Color black(double opacity) => Color.fromRGBO(0, 0, 0, opacity);

  /// Blanco con opacidad
  static Color white(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

  /// Primary con opacidad
  static Color primaryWithOpacity(double opacity) =>
      // ignore: deprecated_member_use
      primary.withOpacity(opacity);

  // ============================================================
  // GRADIENTE PRINCIPAL (Login / Splash background)
  // ============================================================

  /// Inicio del gradiente de fondo (morado-azul)
  static const Color gradientStart = Color(0xFF667eea);

  /// Fin del gradiente de fondo (morado oscuro)
  static const Color gradientEnd = Color(0xFF764ba2);

  ///GRADIANTES PARA GS1
  //static const Color gradientStart = primary;
  //static const Color gradientEnd = Color(0xFF003E73);

  // ============================================================
  // COLORES "ON" PARA SNACKBARS
  // Texto/icono SOBRE el color de fondo del snackbar
  // ============================================================

  /// Ícono/texto sobre snackbar de éxito
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Ícono/texto sobre snackbar de error
  static const Color onError = Color(0xFFFFFFFF);

  /// Ícono/texto sobre snackbar de advertencia (fondo claro → texto oscuro)
  static const Color onWarning = Color(0xFF212121);

  /// Ícono/texto sobre snackbar de info
  static const Color onInfo = Color(0xFFFFFFFF);

  // ============================================================
  // INPUTS
  // ============================================================

  /// Fondo del input
  static const Color inputBackground = Color(0xFFFFFFFF);

  /// Borde normal input
  static const Color inputBorder = grey300;

  /// Borde enfocado input
  static const Color inputFocused = primary;

  /// Hint del input
  static const Color inputHint = grey500;

  /// Texto dentro del input
  static const Color inputText = grey900;

  // ============================================================
  // OTROS (CARDS - DIVIDERS)
  // ============================================================
  static const Color divider = grey200;
  static const Color cardShadow = Color(0x14000000);

  // ============================================================
  // SURFACE VARIANTS
  // ============================================================

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF3F4F6);

  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkVariant = Color(0xFF2A2A2A);
}
