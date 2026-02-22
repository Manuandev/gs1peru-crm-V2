// lib/core/presentation/widgets/buttons/custom_primary_button.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';

/// CustomPrimaryButton — Botón principal de acción de la app
///
/// PROPÓSITO:
/// - Botón relleno (FilledButton) con el color primario de la marca
/// - Maneja estados: habilitado, deshabilitado, cargando
/// - Soporta ícono opcional a la izquierda del texto
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Colores     → [AppColors.primary], [AppColors.textOnDark], [AppColors.grey300]
/// - Espaciado   → [AppSpacing.buttonPaddingHorizontal/Vertical]
/// - Tamaños     → [AppSizing.buttonHeight], [AppSizing.radiusMd], [AppSizing.elevationMedium]
/// - Tipografía  → [AppTextStyles.button]
///
/// USO BÁSICO:
/// ```dart
/// CustomPrimaryButton(
///   text: 'INICIAR SESIÓN',
///   onPressed: _handleLogin,
/// )
/// ```
///
/// CON ESTADO DE CARGA:
/// ```dart
/// CustomPrimaryButton(
///   text: 'GUARDAR',
///   onPressed: _save,
///   isLoading: state is SavingState,
/// )
/// ```
///
/// CON ÍCONO:
/// ```dart
/// CustomPrimaryButton(
///   text: 'SUBIR ARCHIVO',
///   icon: Icon(AppIcons.upload, color: AppColors.textOnDark),
///   onPressed: _uploadFile,
/// )
/// ```
class CustomPrimaryButton extends StatelessWidget {
  // Texto del botón (en mayúsculas por convención)
  final String text;
  // Callback al presionar. null = deshabilita el botón.
  final VoidCallback? onPressed;
  // Si true: muestra un CircularProgressIndicator y deshabilita el botón
  final bool isLoading;
  // Si false: fuerza el estado deshabilitado independientemente de [onPressed]
  final bool isEnabled;
  // Ícono opcional a la izquierda del texto
  final Widget? icon;
  // Ancho del botón. null = ancho completo del padre (double.infinity)
  final double? width;
  // Alto del botón (default: [AppSizing.buttonHeight] = 48px)
  final double? height;
  // Padding personalizado. null = usa [AppSpacing.buttonPaddingHorizontal/Vertical]
  final EdgeInsetsGeometry? padding;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height ,//= AppSizing.buttonHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color backgroundColor = enabled
        ? colorScheme.primary
        // ignore: deprecated_member_use
        : colorScheme.onSurface.withOpacity(0.12);

    final Color foregroundColor = enabled
        ? colorScheme.onPrimary
        // ignore: deprecated_member_use
        : colorScheme.onSurface.withOpacity(0.38);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.buttonPaddingHorizontal,
                vertical: AppSpacing.buttonPaddingVertical,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          elevation: AppSizing.elevationMedium,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  // ✅ Blanco forzado porque está sobre fondo azul primario
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: foregroundColor),
                    child: icon!,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: AppTextStyles.button.copyWith(color: foregroundColor),
              ),
      ),
    );
  }
}
