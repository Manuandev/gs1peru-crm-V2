// lib/core/presentation/widgets/buttons/custom_outlined_button.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

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

  /// Estilo de texto personalizado. Null = usa [AppTextStyles.buttonSecondary].
  /// Útil para botones compactos que necesitan letra más pequeña.
  final TextStyle? textStyle;

  /// Padding interno del botón. Null = usa el default estándar (buttonPaddingH/V).
  /// Útil para botones compactos dentro de tiles o tarjetas.
  final EdgeInsetsGeometry? contentPadding;

  /// Grosor del borde. Null = usa [AppSizing.borderFocusWidth] (2dp).
  /// Útil para variantes compactas que requieren línea más delgada.
  final double? borderWidth;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
    this.textStyle,
    this.contentPadding,
    this.borderWidth,
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
        (enabled
            ? colorScheme.primary
            : theme.disabledColor.withValues(alpha: AppColors.opacityDisabledBorder));

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveBorderColor, width: borderWidth ?? AppSizing.borderFocusWidth),
          padding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSizing.iconMd,
                width: AppSizing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
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
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    text,
                    style: (textStyle ?? AppTextStyles.buttonSecondary).copyWith(
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: (textStyle ?? AppTextStyles.buttonSecondary).copyWith(
                  color: effectiveTextColor,
                ),
              ),
      ),
    );
  }
}
