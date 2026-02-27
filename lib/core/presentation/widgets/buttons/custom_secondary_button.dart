// lib/core/presentation/widgets/buttons/custom_secondary_button.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';

/// CustomSecondaryButton — Botón de acción secundaria
///
/// PROPÓSITO:
/// - Botón relleno con el color secundario (naranja GS1)
/// - Usado para acciones alternativas o de menor jerarquía que [CustomPrimaryButton]
/// - Maneja estados: habilitado, deshabilitado, cargando
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
/// - Colores     → Theme.of(context).colorScheme.secondary
/// - Texto       → colorScheme.onSecondary
/// - Disabled    → theme.disabledColor
/// - Espaciado   → [AppSpacing.buttonPaddingHorizontal/Vertical]
/// - Tamaños     → [AppSizing.buttonHeight], [AppSizing.radiusMd], [AppSizing.elevationLow]
/// - Tipografía  → [AppTextStyles.button]
///
/// CUÁNDO USARLO:
/// - Acción alternativa junto a un botón primario (ej: "Exportar" junto a "Guardar")
/// - Acción positiva pero de segundo nivel de importancia
///
/// USO:
/// ```dart
/// CustomSecondaryButton(
///   text: 'EXPORTAR PDF',
///   icon: Icon(AppIcons.pdf, color: colorScheme.onSurface),
///   onPressed: _exportToPdf,
/// )
/// ```
class CustomSecondaryButton extends StatelessWidget {
  // Texto del botón
  final String text;
  // Callback al presionar. null = deshabilita el botón.
  final VoidCallback? onPressed;
  // Si true: muestra indicador de carga y deshabilita el botón
  final bool isLoading;
  // Si false: fuerza el estado deshabilitado
  final bool isEnabled;
  // Ícono opcional a la izquierda del texto
  final Widget? icon;
  // Ancho del botón. null = ancho completo del padre
  final double? width;
  // Alto del botón (default: [AppSizing.buttonHeight] = 48px)
  final double? height;

  const CustomSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,// = AppSizing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color backgroundColor =
        // ignore: deprecated_member_use
        enabled ? colorScheme.secondary : theme.disabledColor.withOpacity(0.2);

    final Color foregroundColor = enabled
        ? colorScheme.onSecondary
        : theme.disabledColor;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
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
