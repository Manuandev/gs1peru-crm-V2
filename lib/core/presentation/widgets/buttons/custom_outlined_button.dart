// lib/core/presentation/widgets/buttons/custom_outlined_button.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';

/// CustomOutlinedButton — Botón con borde visible y sin relleno
///
/// PROPÓSITO:
/// - Botón outlined (borde + texto de color primario, sin relleno de fondo)
/// - Usado para acciones secundarias o de "cancelar" junto al botón primario
/// - Maneja estados: habilitado, deshabilitado, cargando
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Espaciado   → [AppSpacing.buttonPaddingHorizontal/Vertical]
/// - Tamaños     → [AppSizing.buttonHeight], [AppSizing.radiusMd]
/// - Tipografía  → [AppTextStyles.buttonSecondary]
///
/// CUÁNDO USARLO:
/// - Acción de cancelar / volver
/// - Acción "menos importante" al lado de un botón primario
/// - Cuando el fondo debe mantenerse visible (tarjetas con imagen)
///
/// USO BÁSICO:
/// ```dart
/// CustomOutlinedButton(
///   text: 'CANCELAR',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
///
/// CON COLOR CUSTOM (ej: borde de error):
/// ```dart
/// CustomOutlinedButton(
///   text: 'ELIMINAR',
///   borderColor: colorScheme.error,
///   textColor: colorScheme.error,
///   onPressed: _confirmDelete,
/// )
/// ```
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,// = AppSizing.buttonHeight,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color effectiveTextColor =
        textColor ?? (enabled ? colorScheme.primary : theme.disabledColor);

    final Color effectiveBorderColor =
        borderColor ??
        // ignore: deprecated_member_use
        (enabled ? colorScheme.primary : theme.disabledColor.withOpacity(0.5));

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveBorderColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: effectiveTextColor),
                    child: icon!,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: AppTextStyles.buttonSecondary.copyWith(
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: AppTextStyles.buttonSecondary.copyWith(
                  color: effectiveTextColor,
                ),
              ),
      ),
    );
  }
}
