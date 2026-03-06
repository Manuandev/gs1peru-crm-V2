// lib\features\auth\presentation\widgets\splash\splash_landscape.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

class SplashLandscape extends StatelessWidget {
  const SplashLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          AppIcons.lightning,
          size: AppSizing.iconDisplay,
          color: colorScheme.onPrimary,
        ),
        const SizedBox(width: AppSpacing.xl),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstants.nombreApp,
              style: AppTextStyles.displayLarge.copyWith(
                color: colorScheme.onPrimary,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeMedium,
              color: colorScheme.onPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
