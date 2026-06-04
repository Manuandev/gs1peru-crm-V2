// lib/core/presentation/widgets/buttons/custom_google_button.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// CustomGoogleButton — Botón de autenticación con Google.
///
/// Sigue el mismo sistema de diseño que [CustomPrimaryButton]
/// pero con estilo outlined y logo de Google.
///
/// USO:
/// ```dart
/// CustomGoogleButton(
///   onPressed: _handleGoogleLogin,
///   isLoading: isLoading,
/// )
/// ```
class CustomGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomGoogleButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height, // = AppSizing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final String label = size.shortestSide < 400
        ? 'Con Google'
        : 'Ingresar con Google';

    final bool enabled = !isLoading && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          side: BorderSide(
            color: enabled
                ? colorScheme.outline
                : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledBg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSizing.iconMd,
                width: AppSizing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
                  color: colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: AppSizing.iconMd,
                    width: AppSizing.iconMd,
                    child: SvgPicture.asset(
                      AppImages.logoGoogle,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledFg),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
