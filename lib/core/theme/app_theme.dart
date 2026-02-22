// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';

/// Tema de la Aplicación
///
/// PROPÓSITO:
/// - Theme consistente en toda la app
/// - Usa AppColors para todos los colores
/// - Configura estilos de widgets por defecto
/// - Un solo lugar para el theme
///
/// USO en main.dart:
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// )
class AppTheme {
  // Prevenir instanciación
  AppTheme._();

  // ============================================================
  // TEMA CLARO (Light Theme)
  // ============================================================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      // Colores principales
      primary: AppColors.primary,
      onPrimary: Colors.white,
      // ignore: deprecated_member_use
      primaryContainer: AppColors.primary.withOpacity(0.1),
      onPrimaryContainer: AppColors.primary,

      // Colores secundarios
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      // ignore: deprecated_member_use
      secondaryContainer: AppColors.secondary.withOpacity(0.1),
      onSecondaryContainer: AppColors.secondary,

      // Colores de superficie
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      // Colores de error
      error: AppColors.error,
      onError: Colors.white,
      // ignore: deprecated_member_use
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,

      // Outline
      outline: AppColors.border,
      // ignore: deprecated_member_use
      outlineVariant: AppColors.border.withOpacity(0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,

      // ============================================================
      // COLOR SCHEME
      // ============================================================
      colorScheme: colorScheme,

      // ============================================================
      // APP BAR THEME
      // ============================================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ============================================================
      // ELEVATED BUTTON (FilledButton)
      // ============================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppSizing.elevationMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          minimumSize: const Size(double.infinity, AppSizing.buttonHeight),
        ),
      ),

      // ============================================================
      // OUTLINED BUTTON
      // ============================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          minimumSize: const Size(double.infinity, AppSizing.buttonHeight),
        ),
      ),

      // ============================================================
      // TEXT BUTTON
      // ============================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
        ),
      ),

      // ============================================================
      // INPUT DECORATION (TextFields)
      // ============================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,

        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),

        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),

      // ============================================================
      // CARD THEME
      // ============================================================
      cardTheme: CardThemeData(
        color: colorScheme.surface,

        elevation: 2,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
      ),

      // ============================================================
      // DIALOG THEME
      // ============================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSizing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        ),
      ),

      // ============================================================
      // BOTTOM SHEET THEME
      // ============================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSizing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizing.radiusLg),
          ),
        ),
      ),

      // ============================================================
      // SNACKBAR THEME
      // ============================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
      ),

      // ============================================================
      // ICON THEME
      // ============================================================
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSizing.iconMd,
      ),

      // ============================================================
      // DIVIDER THEME
      // ============================================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),

      // ============================================================
      // CHIP THEME
      // ============================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        // ignore: deprecated_member_use
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
      ),

      // ============================================================
      // SWITCH THEME
      // ============================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.grey300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey300;
        }),
      ),

      // ============================================================
      // CHECKBOX THEME
      // ============================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusXs),
        ),
      ),

      // ============================================================
      // RADIO THEME
      // ============================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
      ),

      // ============================================================
      // TEXT THEME
      // ============================================================
      textTheme:
          const TextTheme(
            displayLarge: AppTextStyles.displayLarge,
            displayMedium: AppTextStyles.displayMedium,
            headlineLarge: AppTextStyles.headlineLarge,
            headlineMedium: AppTextStyles.headlineMedium,
            headlineSmall: AppTextStyles.headlineSmall,
            titleLarge: AppTextStyles.titleLarge,
            titleMedium: AppTextStyles.titleMedium,
            titleSmall: AppTextStyles.titleSmall,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
            labelLarge: AppTextStyles.labelLarge,
            labelMedium: AppTextStyles.labelMedium,
            labelSmall: AppTextStyles.labelSmall,
          ).apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
    );
  }

  // ============================================================
  // TEMA OSCURO (Dark Theme)
  // ============================================================

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      // ignore: deprecated_member_use
      primaryContainer: AppColors.primary.withOpacity(0.2),
      onPrimaryContainer: AppColors.primary,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,

      surface: AppColors.surfaceDark,
      onSurface: AppColors.textOnDark,

      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      colorScheme: colorScheme,

      // Reutilizar la mayoría de configuraciones del light theme
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      elevatedButtonTheme: lightTheme.elevatedButtonTheme,
      outlinedButtonTheme: lightTheme.outlinedButtonTheme,
      textButtonTheme: lightTheme.textButtonTheme,

      // ============================================================
      // INPUT DECORATION (TextFields)
      // ============================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkVariant,

        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),

        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),

      // ============================================================
      // CARD THEME
      // ============================================================
      cardTheme: CardThemeData(
        color: colorScheme.surface,

        elevation: 2,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
      ),

      dialogTheme: lightTheme.dialogTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),

      textTheme: lightTheme.textTheme.apply(
        bodyColor: AppColors.textOnDark,
        displayColor: AppColors.textOnDark,
      ),
    );
  }
}
