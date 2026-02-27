// lib/core/presentation/widgets/buttons/custom_text_button.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';

/// CustomTextButton — Botón de texto sin fondo ni borde
///
/// PROPÓSITO:
/// - Botón de mínima jerarquía visual: solo texto (y ícono opcional)
/// - Ideal para links en formularios ("¿Olvidaste tu contraseña?")
/// - Permite personalizar color, tamaño y peso sin romper el sistema
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Espaciado   → [AppSpacing.sm], [AppSpacing.xs]
/// - Tipografía  → [AppTextStyles.buttonSmall] como base
///
/// USO BÁSICO:
/// ```dart
/// CustomTextButton(
///   text: '¿Olvidaste tu contraseña?',
///   onPressed: () => context.goToForgotPassword(),
/// )
/// ```
///
/// CON COLOR CUSTOM (ej: link de error):
/// ```dart
/// CustomTextButton(
///   text: 'Reintentar',
///   onPressed: _retry,
/// )
/// ```
///
/// CON ÍCONO:
/// ```dart
/// CustomTextButton(
///   text: 'Ver más',
///   icon: Icon(AppIcons.forward, size: AppSizing.iconSm),
///   onPressed: _showMore,
/// )
/// ```
class CustomTextButton extends StatelessWidget {
  // Texto del botón
  final String text;
  // Callback al presionar. null = deshabilita el botón.
  final VoidCallback? onPressed;
  // Color del texto e ícono. 
  final Color? textColor;
  // Tamaño de fuente custom. null = usa el de [AppTextStyles.buttonSmall]
  final double? fontSize;
  // Peso de fuente custom. null = usa el de [AppTextStyles.buttonSmall]
  final FontWeight? fontWeight;
  // Ícono opcional (izquierda del texto)
  final Widget? icon;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si no tiene ninguna funcion no se podra presionar
    final bool enabled = onPressed != null;

    final Color effectiveColor =
        textColor ?? (enabled ? colorScheme.primary : theme.disabledColor);

    // Base desde AppTextStyles — el caller puede sobreescribir fontSize/fontWeight
    final TextStyle style = AppTextStyles.buttonSmall.copyWith(
      color: effectiveColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(color: effectiveColor),
                  child: icon!,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(text, style: style),
              ],
            )
          : Text(text, style: style),
    );
  }
}
