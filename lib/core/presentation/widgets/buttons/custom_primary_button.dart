// lib/core/presentation/widgets/buttons/custom_primary_button.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// CustomPrimaryButton — Botón principal de acción de la app
///
/// PROPÓSITO:
/// - Botón relleno (FilledButton) con el color primario de la marca
/// - Maneja estados: habilitado, deshabilitado, cargando
/// - Soporta ícono opcional a la izquierda del texto
///
/// DEPENDENCIAS DEL SISTEMA DE DISEÑO:
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
///   icon: Icon(AppIcons.upload, color: colorScheme.onSurface),
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
  // Color de fondo personalizado. null = usa colorScheme.primary (azul corporativo)
  final Color? backgroundColor;
  // Color de texto/ícono personalizado. null = usa colorScheme.onPrimary (blanco)
  final Color? foregroundColor;
  // Estilo de texto personalizado. null = usa AppTextStyles.button (16px bold)
  final TextStyle? textStyle;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color resolvedBg = backgroundColor ?? colorScheme.primary;
    final Color resolvedFg = foregroundColor ?? colorScheme.onPrimary;

    final Color resolvedBackgroundColor = enabled
        ? resolvedBg
        : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledBg);

    final Color resolvedForegroundColor = enabled
        ? resolvedFg
        : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledFg);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: resolvedBackgroundColor,
          disabledBackgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedForegroundColor,
          disabledForegroundColor: resolvedForegroundColor,
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
                height: AppSizing.iconMd,
                width: AppSizing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
                  valueColor: AlwaysStoppedAnimation<Color>(resolvedForegroundColor),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: resolvedForegroundColor),
                    child: icon!,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      text,
                      style: (textStyle ?? AppTextStyles.button).copyWith(
                        color: resolvedForegroundColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: (textStyle ?? AppTextStyles.button).copyWith(color: resolvedForegroundColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
