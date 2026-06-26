// lib/core/presentation/widgets/buttons/custom_outlined_button.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import '_icon_resolver.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
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
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool enabled = isEnabled && !isLoading && onPressed != null;

    final Color resolvedFg = foregroundColor ??
        (enabled ? colorScheme.primary : Theme.of(context).disabledColor);

    final Color resolvedBorder = borderColor ??
        (enabled
            ? colorScheme.primary
            : Theme.of(context)
                .disabledColor
                .withValues(alpha: AppColors.opacityDisabledBorder));

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: resolvedFg,
      side: BorderSide(color: resolvedBorder, width: borderWidth ?? 1.0),
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
          ? OutlinedButton.icon(
              onPressed: enabled ? onPressed : null,
              style: buttonStyle,
              icon: resolveIcon(icon!, AppSizing.iconActionSm, resolvedFg),
              label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
