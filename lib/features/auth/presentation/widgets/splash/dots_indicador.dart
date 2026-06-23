// lib/features/auth/presentation/widgets/splash/dots_indicador.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Indicador de posición animado para el carrusel de onboarding.
///
/// [sobreFondoAzul] = true  → dots blancos (slide 1)
/// [sobreFondoAzul] = false → dot activo azul, inactivos gris (slides 2-6)
class DotsIndicador extends StatelessWidget {
  const DotsIndicador({
    super.key,
    required this.total,
    required this.actual,
    required this.sobreFondoAzul,
  });

  final int total;
  final int actual;
  final bool sobreFondoAzul;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final estaActivo = i == actual;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: estaActivo ? 10.0 : 8.0,
            height: estaActivo ? 10.0 : 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorDot(estaActivo),
            ),
          ),
        );
      }),
    );
  }

  Color _colorDot(bool activo) {
    if (sobreFondoAzul) {
      return activo ? Colors.white : Colors.white.withValues(alpha: 0.4);
    }
    return activo ? AppColors.primary : AppColors.border;
  }
}
