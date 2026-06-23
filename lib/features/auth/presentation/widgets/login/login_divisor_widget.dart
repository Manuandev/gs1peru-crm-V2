// lib/features/auth/presentation/widgets/login/login_divisor_widget.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

/// Divisor horizontal con un punto central para separar
/// la opción de Google del formulario de credenciales.
class LoginDivisorWidget extends StatelessWidget {
  const LoginDivisorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.border, thickness: AppSizing.hairline),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: AppSizing.hairline),
        ),
      ],
    );
  }
}
