// lib/features/auth/presentation/widgets/splash/onboarding_slide3.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 3: "Conversaciones inteligentes"
class OnboardingSlide3 extends StatelessWidget {
  const OnboardingSlide3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideBase(
      titulo: 'Conversaciones\ninteligentes',
      subtitulo:
          'Visualiza conversaciones de WhatsApp y CTWA,\nresponde rápido y controla el tiempo sin respuesta.',
      mockup: const _MockupBandeja(),
      elementosFlotantes: (cardTop) => [
        // Superior izquierda del card
        Positioned(
          top: cardTop - 22,
          left: 4,
          child: _CirculoFlotante(color: const Color(0xFF25D366), icono: AppIcons.chat),
        ),
        // Lado izquierdo, ~1/3 del card
        Positioned(
          top: cardTop + 100,
          left: 4,
          child: _CirculoFlotante(color: AppColors.primary, icono: AppIcons.message),
        ),
        // Superior derecha del card
        Positioned(
          top: cardTop - 22,
          right: 4,
          child: _CirculoFlotante(color: AppColors.onboardingPurple, icono: AppIcons.accessTime),
        ),
        // Lado derecho, ~1/3 del card
        Positioned(
          top: cardTop + 100,
          right: 4,
          child: _CirculoFlotante(color: AppColors.primary, icono: AppIcons.notificationFilled),
        ),
      ],
    );
  }
}

// ── Mockup bandeja ─────────────────────────────────────────────────────────────

class _MockupBandeja extends StatelessWidget {
  const _MockupBandeja();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs,
            ),
            child: Text(
              'Bandeja de conversaciones',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: AppTextStyles.weightBold),
            ),
          ),
          const _TabsBandeja(),
          const Divider(height: 1),
          _BuscadorMini(),
          const Divider(height: 1),
          const _ItemConversacion(
            nombre: 'María Rodríguez',
            mensaje: '¿Tienen disponibilidad del producto GS1?',
            hora: '09:41',
            badge: 2,
            canalId: 1,
            destacado: false,
          ),
          const _ItemConversacion(
            nombre: 'Carlos López',
            mensaje: 'Necesito ayuda con la implementación.',
            hora: '02:15',
            badge: 1,
            canalId: 7,
            destacado: true,
            tiempoVencido: true,
          ),
          const _ItemConversacion(
            nombre: 'Ana Torres',
            mensaje: 'Gracias, quedo atento a su respuesta.',
            hora: 'Ayer',
            badge: 1,
            canalId: 1,
            destacado: false,
          ),
          const Divider(height: 1),
          _FooterMetricas(),
        ],
      ),
    );
  }
}

class _TabsBandeja extends StatelessWidget {
  const _TabsBandeja();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _Tab(label: 'Todas', badge: 24, activo: true),
          const SizedBox(width: AppSpacing.md),
          _Tab(label: 'WhatsApp', badge: 14, activo: false),
          const SizedBox(width: AppSpacing.md),
          _Tab(label: 'CTWA', badge: 10, activo: false),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.badge, required this.activo});
  final String label;
  final int badge;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: activo ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: activo ? AppTextStyles.weightBold : AppTextStyles.weightRegular,
                ),
              ),
              const SizedBox(width: 3),
              if (activo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                  ),
                  child: Text(
                    '$badge',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 9),
                  ),
                ),
            ],
          ),
        ),
        if (activo)
          Container(height: 2, width: 40, color: AppColors.primary)
        else
          const SizedBox(height: 2),
      ],
    );
  }
}

class _BuscadorMini extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.search, size: AppSizing.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Buscar conversación',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const Icon(AppIcons.filter, size: AppSizing.iconSm, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _ItemConversacion extends StatelessWidget {
  const _ItemConversacion({
    required this.nombre,
    required this.mensaje,
    required this.hora,
    required this.badge,
    required this.canalId,
    required this.destacado,
    this.tiempoVencido = false,
  });

  final String nombre;
  final String mensaje;
  final String hora;
  final int badge;
  final int canalId;
  final bool destacado;
  final bool tiempoVencido;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: destacado ? AppColors.error.withValues(alpha: 0.05) : null,
        border: destacado
            ? const Border(left: BorderSide(color: AppColors.error, width: 3))
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.grey200,
            child: Text(
              nombre[0],
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSocialUtils.widgetCanalById(canalId, size: 10),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        nombre,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tiempoVencido)
                      _ChipTiempoVencido(hora: hora)
                    else
                      Text(
                        hora,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _Badge(valor: badge),
        ],
      ),
    );
  }
}

class _ChipTiempoVencido extends StatelessWidget {
  const _ChipTiempoVencido({required this.hora});
  final String hora;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
        border: Border.all(color: AppColors.error, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.accessTime, size: 9, color: AppColors.error),
          const SizedBox(width: 2),
          Text(
            hora,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.valor});
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$valor',
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 9),
        ),
      ),
    );
  }
}

class _FooterMetricas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Text(
            'Tiempo promedio de respuesta',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9),
          ),
          const Spacer(),
          Text(
            '01:45 min',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
            child: Text(
              '-32% vs. ayer ✓',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 8),
            ),
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

