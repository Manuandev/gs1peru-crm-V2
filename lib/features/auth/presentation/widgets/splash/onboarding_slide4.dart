// lib/features/auth/presentation/widgets/splash/onboarding_slide4.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 4: "Seguimiento de prospectos"
class OnboardingSlide4 extends StatelessWidget {
  const OnboardingSlide4({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideBase(
      titulo: 'Seguimiento de\nprospectos',
      subtitulo:
          'Gestiona leads, registra comentarios,\nactividades y negociaciones desde una sola vista.',
      mockup: const _MockupSeguimiento(),
      elementosFlotantes: (cardTop) => [
        // Superior izquierda del card
        Positioned(
          top: cardTop - 22,
          left: 4,
          child: _CirculoFlotante(color: AppColors.primary, icono: AppIcons.userFilled),
        ),
        // Superior derecha del card
        Positioned(
          top: cardTop - 22,
          right: 4,
          child: _CirculoFlotante(color: AppColors.onboardingPurple, icono: AppIcons.business),
        ),
        // Lado derecho, ~1/3 del card
        Positioned(
          top: cardTop + 100,
          right: 4,
          child: _CirculoFlotante(color: AppColors.success, icono: AppIcons.accessTime),
        ),
      ],
    );
  }
}

// ── Mockup principal ───────────────────────────────────────────────────────────

class _MockupSeguimiento extends StatelessWidget {
  const _MockupSeguimiento();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.grey200,
                child: Icon(AppIcons.business, size: AppSizing.iconSm, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Industrias SAC',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.weightBold)),
                    Text('Contacto: Juan Pérez',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _ChipLead(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Estado actual',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxs),
          _ChipEstado(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ActividadesRecientes()),
              const SizedBox(width: AppSpacing.sm),
              _CardEtapa(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _CardProximaActividad(),
        ],
      ),
    );
  }
}

class _ChipLead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
        color: AppColors.primaryWithOpacity(0.08),
      ),
      child: Text('Lead',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryWithOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text('En seguimiento',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _ActividadesRecientes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividad reciente',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.weightBold)),
        const SizedBox(height: AppSpacing.xs),
        _ItemActividad(
          color: AppColors.primary,
          icono: AppIcons.phone,
          titulo: 'Llamada de seguimiento',
          fecha: 'Hoy, 10:30 a. m.',
        ),
        _ItemActividad(
          color: AppColors.success,
          icono: AppIcons.email,
          titulo: 'Correo enviado',
          fecha: 'Ayer, 4:15 p. m.',
        ),
        _ItemActividad(
          color: AppColors.warning,
          icono: AppIcons.calendar,
          titulo: 'Reunión agendada',
          fecha: '12 jun, 11:00 a. m.',
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Ver todas las actividades ›',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _ItemActividad extends StatelessWidget {
  const _ItemActividad({
    required this.color,
    required this.icono,
    required this.titulo,
    required this.fecha,
  });
  final Color color;
  final IconData icono;
  final String titulo;
  final String fecha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 12, color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(fecha,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardEtapa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const etapas = ['Cont.', 'Calif.', 'Prop.', 'Neg.'];
    const activa = 2;

    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Etapa en el proceso',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: AppTextStyles.weightBold,
                fontSize: 8,
              )),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: List.generate(etapas.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Expanded(
                  child: Container(
                    height: 1,
                    color: i < activa * 2 ? AppColors.primary : AppColors.border,
                  ),
                );
              }
              final idx = i ~/ 2;
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: idx <= activa ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: idx <= activa ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: etapas
                .map((e) => Expanded(
                      child: Text(e,
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 6),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Actual: Propuesta',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 7,
              )),
        ],
      ),
    );
  }
}

class _CardProximaActividad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.calendar, size: AppSizing.iconSm, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reunión de propuesta',
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.weightBold)),
                Text('14 jun, 10:00 a. m.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
            child: Text('Programada',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

// ── Flotantes ──────────────────────────────────────────────────────────────────

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
