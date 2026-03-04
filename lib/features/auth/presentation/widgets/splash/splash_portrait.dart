// lib/features/auth/presentation/widgets/login_portrait_card.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

class SplashPortrait extends StatelessWidget {
  const SplashPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          AppIcons.lightning,
          size: AppSizing.iconDisplay,
          color: colorScheme.onPrimary,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'MI APP',
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
    );
  }
}
