// lib/features/auth/presentation/widgets/splash/onboarding_slide2.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 2: "Bienvenido a CRM Perú"
class OnboardingSlide2 extends StatelessWidget {
  const OnboardingSlide2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideBase(
      titulo: 'Bienvenido a\nCRM Perú',
      subtitulo: 'Gestiona conversaciones, prospectos,\nsolicitudes y cobranzas en un solo lugar.',
      mockup: const _MockupBienvenido(),
      elementosFlotantes: (cardTop) => [
        // Esquina superior izquierda del card
        Positioned(
          top: cardTop - 22,
          left: 4,
          child: _CirculoFlotante(color: AppColors.primary, icono: AppIcons.chat),
        ),
        // Lado izquierdo, ~1/3 del card
        Positioned(
          top: cardTop + 90,
          left: 4,
          child: _CirculoFlotante(color: AppColors.onboardingPurple, icono: AppIcons.moneda),
        ),
        // Esquina superior derecha del card
        Positioned(
          top: cardTop - 22,
          right: 4,
          child: _CirculoFlotante(color: AppColors.success, icono: AppIcons.userFilled),
        ),
        // Lado derecho, ~1/3 del card
        Positioned(
          top: cardTop + 90,
          right: 4,
          child: _CardMiniBarras(),
        ),
      ],
    );
  }
}

// ── Mockup principal ───────────────────────────────────────────────────────────

class _MockupBienvenido extends StatelessWidget {
  const _MockupBienvenido();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(AppIcons.userFilled, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Linea(width: 90, height: 8),
                    const SizedBox(height: 4),
                    _Linea(width: 60, height: 6),
                  ],
                ),
              ),
              _ChipCrm(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLightVariant,
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: _Linea(width: 120, height: 8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: const Icon(AppIcons.moreHorizontal, color: Colors.white, size: AppSizing.iconSm),
            ),
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(AppIcons.users, size: AppSizing.iconSm, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text('Prospecto', style: AppTextStyles.bodySmall),
              const Spacer(),
              _ChipCalificado(),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Text(
            'Flujo de trabajo',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.weightBold),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _StepperFlujo(),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
    );
  }
}

class _ChipCrm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
      ),
      child: Text(
        'CRM',
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ChipCalificado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
        border: Border.all(color: AppColors.success, width: 0.8),
      ),
      child: Text(
        'Calificado',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
      ),
    );
  }
}

class _StepperFlujo extends StatelessWidget {
  const _StepperFlujo();

  static const _pasos = [
    (AppIcons.chat, 'Conversación'),
    (AppIcons.userFilled, 'Prospecto'),
    (AppIcons.file, 'Solicitud'),
    (AppIcons.moneda, 'Cobranza'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_pasos.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(child: Container(height: 1.5, color: AppColors.success));
        }
        final paso = _pasos[i ~/ 2];
        return _PasoFlujo(icono: paso.$1, label: paso.$2);
      }),
    );
  }
}

class _PasoFlujo extends StatelessWidget {
  const _PasoFlujo({required this.icono, required this.label});
  final IconData icono;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: Icon(icono, color: Colors.white, size: AppSizing.iconSm),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Flotantes helpers ──────────────────────────────────────────────────────────

class _CirculoFlotante extends StatelessWidget {
  const _CirculoFlotante({required this.color, required this.icono});
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Icon(icono, color: Colors.white, size: AppSizing.iconActionSm),
    );
  }
}

class _CardMiniBarras extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BarraMini(alto: 14),
          const SizedBox(width: 2),
          _BarraMini(alto: 22),
          const SizedBox(width: 2),
          _BarraMini(alto: 10),
        ],
      ),
    );
  }
}

class _BarraMini extends StatelessWidget {
  const _BarraMini({required this.alto});
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: alto,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }
}
