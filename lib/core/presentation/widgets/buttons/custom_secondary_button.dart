// lib/core/presentation/widgets/buttons/custom_secondary_button.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Object? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  // Tamaño del ícono. null = AppSizing.iconActionSm.
  final double? iconSize;

  const CustomSecondaryButton({
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
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color resolvedBg = backgroundColor ?? AppColors.secondary;
    final Color resolvedFg = foregroundColor ?? AppColors.textOnDark;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: enabled
          ? resolvedBg
          : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledBg),
      foregroundColor: enabled
          ? resolvedFg
          : colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledFg),
      disabledBackgroundColor:
          colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledBg),
      disabledForegroundColor:
          colorScheme.onSurface.withValues(alpha: AppColors.opacityDisabledFg),
      minimumSize: Size.fromHeight(height ?? AppSizing.buttonHeightSmall),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      textStyle: (textStyle ??
              AppTextStyles.labelMedium.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ))
          .copyWith(inherit: true),
      elevation: AppSizing.elevationMin,
    );

    final Widget child = isLoading
        ? SizedBox(
            height: AppSizing.iconMd,
            width: AppSizing.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeSmall,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedFg),
            ),
          )
        : Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);

    return SizedBox(
      width: width ?? double.infinity,
      child: icon != null && !isLoading
          ? ElevatedButton.icon(
              onPressed: enabled ? onPressed : null,
              style: buttonStyle,
              icon: resolveIcon(
                icon!,
                iconSize ?? AppSizing.iconActionSm,
                resolvedFg,
              ),
              label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          : ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
