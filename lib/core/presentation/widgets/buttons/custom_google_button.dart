// lib/core/presentation/widgets/buttons/custom_google_button.dart

// ignore_for_file: deprecated_member_use

import 'package:app_crm/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:flutter_svg/svg.dart';

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
                : colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
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
                          // ignore: duplicate_ignore
                          : colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
