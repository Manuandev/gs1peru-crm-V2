// lib\core\errors\app_error_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorIconSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: AppSizing.iconErrorSm,
      tablet: AppSizing.iconErrorMd,
      desktop: AppSizing.iconXxl,
    );
    final errorTextSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: AppTextStyles.sizeMd,
      tablet: AppTextStyles.sizeBase,
      desktop: AppTextStyles.sizeLg,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.wifiOff,
              size: errorIconSize,
              color: AppColors.grey300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
                fontSize: errorTextSize,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomPrimaryButton(
              text: 'Reintentar',
              icon: const Icon(AppIcons.refresh),
              onPressed: onRetry,
              width: null,
            ),
          ],
        ),
      ),
    );
  }
}
