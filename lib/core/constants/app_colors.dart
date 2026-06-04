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
  static const Color primary = Color(0xFF002C6C);

  /// Color secundario - Naranja corporativo GS1
  static const Color secondary = Color(0xFFF26334);

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
  // GRADIENTE PRINCIPAL (Login background)
  // ============================================================

  /// Inicio del gradiente de fondo Login (morado-azul)
  static const Color gradientStart = Color(0xFF667eea);

  /// Fin del gradiente de fondo Login (morado oscuro)
  static const Color gradientEnd = Color(0xFF764ba2);

  // ============================================================
  // GRADIENTE SPLASH — Azul corporativo GS1
  // ============================================================

  /// Extremo claro del gradiente del Splash (azul GS1 medio)
  static const Color primaryLight = Color(0xFF003E73);

  // ── Anillos decorativos del Splash (blanco semitransparente sobre fondo oscuro)

  /// Blanco 15% — anillo exterior del Splash
  static const Color splashRing1 = Color(0x26FFFFFF);

  /// Blanco 10% — anillo medio del Splash
  static const Color splashRing2 = Color(0x1AFFFFFF);

  /// Blanco 7% — anillo interior del Splash
  static const Color splashRing3 = Color(0x12FFFFFF);

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

  /// Color del ícono de estrella/favorito activo (Amber 500 Material) — LeadCardActions
  static const Color favorito = Color(0xFFFFC107);

  // ============================================================
  // SURFACE VARIANTS
  // ============================================================

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF3F4F6);

  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkVariant = Color(0xFF2A2A2A);

  // ============================================================
  // TRANSPARENTE
  // ============================================================

  /// Color completamente transparente
  static const Color transparent = Color(0x00000000);

  // ============================================================
  // OPACIDADES MATERIAL 3 (estados de controles interactivos)
  // Úsalas con .withValues(alpha: AppColors.opacityXxx)
  // sobre colorScheme tokens — no como colores absolutos.
  // ============================================================

  /// Fondo de control deshabilitado (Material 3 estándar): 12%
  static const double opacityDisabledBg = 0.12;

  /// Texto/ícono de control deshabilitado (Material 3 estándar): 38%
  static const double opacityDisabledFg = 0.38;

  /// Borde de control deshabilitado: 50%
  static const double opacityDisabledBorder = 0.5;

  /// Fondo muy sutil de control deshabilitado (secundario): 20%
  static const double opacitySubtle = 0.2;

  /// Ítem activo en drawer / nav rail: 12% del color primario
  static const double opacityActiveItem = 0.12;

  /// Texto/subtítulo sobre fondo primario oscuro: 80%
  static const double opacityOnPrimarySubtle = 0.8;

  /// Hint / placeholder sobre surface: 50%
  static const double opacityHint = 0.5;

  /// Texto de cuerpo semitransparente (ej: mensaje en snackbar): 85%
  static const double opacityBodyText = 0.85;

  /// Overlay de presión visible sobre fondos oscuros (AppBar, headers): 24%
  /// Material 3 pressed-state sobre onPrimary — más perceptible que opacityActiveItem (12%)
  static const double opacityPressedOnDark = 0.24;

  /// Fondo translúcido de avatar derivado por nombre (ProspectoTile): 15%
  static const double opacityAvatarBg = 0.15;

  /// Sombra coloreada de DashboardCard (caja de sombra sobre color primario): 30%
  static const double opacityShadow = 0.30;

  /// Divider semitransparente en sections de home: 30%
  static const double opacityDivider = 0.30;

  /// Texto secundario muy atenuado en tiles de notificación: 60%
  static const double opacityTextMuted = 0.60;

  /// Texto de estado vacío / empty state: 40%
  static const double opacityEmptyText = 0.40;

  /// Íconos muy sutiles sobre fondos de card (CardTotalesHome subtítulos): 71%
  static const double opacityIconMuted = 0.71;

  // ============================================================
  // SNACKBAR / TOAST — Paletas semánticas modo oscuro
  // Fondos oscuros consistentes para notificaciones en ambos temas.
  // Referenciados en app_snackbar.dart (_SnackConfig).
  // ============================================================

  /// Fondo del snackbar de éxito (verde oscuro)
  static const Color snackSuccessBg = Color(0xFF1B2E1C);

  /// Fondo del contenedor de ícono — snackbar éxito
  static const Color snackSuccessIconBg = Color(0xFF2D4A2F);

  /// Color del ícono — snackbar éxito
  static const Color snackSuccessIcon = Color(0xFF81C784);

  /// Color del texto — snackbar éxito
  static const Color snackSuccessText = Color(0xFFD4EDDA);

  /// Fondo del snackbar de error (rojo oscuro)
  static const Color snackErrorBg = Color(0xFF2E1B1B);

  /// Fondo del contenedor de ícono — snackbar error
  static const Color snackErrorIconBg = Color(0xFF4A2D2D);

  /// Color del ícono — snackbar error
  static const Color snackErrorIcon = Color(0xFFE57373);

  /// Color del texto — snackbar error
  static const Color snackErrorText = Color(0xFFF8D7DA);

  /// Fondo del snackbar de advertencia (ámbar oscuro)
  static const Color snackWarningBg = Color(0xFF2E2418);

  /// Fondo del contenedor de ícono — snackbar advertencia
  static const Color snackWarningIconBg = Color(0xFF4A3820);

  /// Color del ícono — snackbar advertencia
  static const Color snackWarningIcon = Color(0xFFFFB74D);

  /// Color del texto — snackbar advertencia
  static const Color snackWarningText = Color(0xFFFFF3CD);

  /// Fondo del snackbar informativo (azul oscuro)
  static const Color snackInfoBg = Color(0xFF1B2435);

  /// Fondo del contenedor de ícono — snackbar info
  static const Color snackInfoIconBg = Color(0xFF253654);

  /// Color del ícono — snackbar info
  static const Color snackInfoIcon = Color(0xFF64B5F6);

  /// Color del texto — snackbar info
  static const Color snackInfoText = Color(0xFFD0E8FB);
}
