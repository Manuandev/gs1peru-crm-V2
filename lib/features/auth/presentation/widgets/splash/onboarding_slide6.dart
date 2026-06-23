// lib/features/auth/presentation/widgets/splash/onboarding_slide6.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 6: "Cobranzas bajo control"
/// La navegación al pulsar "Empezar" la gestiona OnboardingCarousel.
class OnboardingSlide6 extends StatelessWidget {
  const OnboardingSlide6({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideBase(
      titulo: 'Cobranzas\nbajo control',
      subtitulo:
          'Factura al contado o crédito, gestiona\nplanes de pago y da seguimiento a cada cobro.',
      mockup: const _MockupCobranza(),
      elementosFlotantes: (cardTop) => [
        // Superior izquierda del card
        Positioned(
          top: cardTop - 22,
          left: 4,
          child: _CirculoFlotante(color: AppColors.onboardingPurple, icono: AppIcons.moneda),
        ),
        // Lado izquierdo, ~1/3 del card
        Positioned(
          top: cardTop + 90,
          left: 4,
          child: _CirculoFlotante(color: AppColors.primary, icono: AppIcons.fileFactura),
        ),
        // Superior derecha del card
        Positioned(
          top: cardTop - 22,
          right: 4,
          child: _CirculoFlotante(color: AppColors.success, icono: AppIcons.checkCircleFilled),
        ),
        // Lado derecho, ~1/3 del card
        Positioned(
          top: cardTop + 90,
          right: 4,
          child: _CardCartera(),
        ),
      ],
    );
  }
}

// ── Mockup principal ───────────────────────────────────────────────────────────

class _MockupCobranza extends StatelessWidget {
  const _MockupCobranza();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                  Expanded(
                    child: Text('Resumen de cobranza',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        )),
                  ),
                  const Icon(AppIcons.moreHorizontal, size: AppSizing.iconSm),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total por cobrar',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        Text('S/ 45,680.00',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: AppTextStyles.weightBold,
                            )),
                        Text('12 documentos',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _IndicadorCircular(),
                ],
              ),
              const Divider(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _Metrica(
                    label: 'Vencido',
                    valor: 'S/ 12,560.00',
                    color: AppColors.error,
                    docs: '4 documentos',
                  )),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _Metrica(
                    label: 'Por vencer',
                    valor: 'S/ 33,120.00',
                    color: AppColors.primary,
                    docs: '8 documentos',
                  )),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Documentos recientes',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.weightBold)),
              const SizedBox(height: AppSpacing.xs),
              _FilaDocumento(numero: 'F001-000123', monto: 'S/ 3,560.00', estado: 'Vencido', colorEstado: AppColors.error),
              _FilaDocumento(numero: 'F001-000124', monto: 'S/ 2,880.00', estado: 'Pagado', colorEstado: AppColors.success),
              _FilaDocumento(numero: 'F001-000125', monto: 'S/ 1,250.00', estado: 'Por vencer', colorEstado: AppColors.warning),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizing.radiusLg),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: const _PlanPago(),
        ),
      ],
    );
  }
}

class _IndicadorCircular extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('70%',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    fontSize: 11,
                    color: AppColors.primary,
                  )),
              Text('Cobrado',
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 7, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.label,
    required this.valor,
    required this.color,
    required this.docs,
  });
  final String label;
  final String valor;
  final Color color;
  final String docs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        Text(valor,
            style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: AppTextStyles.weightBold)),
        Text(docs, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9)),
      ],
    );
  }
}

class _FilaDocumento extends StatelessWidget {
  const _FilaDocumento({
    required this.numero,
    required this.monto,
    required this.estado,
    required this.colorEstado,
  });
  final String numero;
  final String monto;
  final String estado;
  final Color colorEstado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(AppIcons.fileFactura, size: AppSizing.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(numero, style: AppTextStyles.labelSmall.copyWith(fontSize: 10))),
          Text(monto,
              style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.weightBold, fontSize: 10)),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
            child: Text(estado,
                style: AppTextStyles.labelSmall.copyWith(color: colorEstado, fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _PlanPago extends StatelessWidget {
  const _PlanPago();

  static const _hitoPagados = 2;
  static const _hitos = [
    _HitoData('Inicial', 'S/ 10,000', 'Pagado', true),
    _HitoData('Cuota 1', 'S/ 8,000', 'Pagado', true),
    _HitoData('Cuota 2', 'S/ 8,000', 'Pendiente', false),
    _HitoData('Cuota 3', 'S/ 7,680', 'Pendiente', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Plan de pago',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.weightBold)),
            ),
            const Icon(AppIcons.calendar, size: AppSizing.iconSm, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(_hitos.length * 2 - 1, (i) {
            if (i.isOdd) {
              final pagado = i < (_hitoPagados * 2);
              return Expanded(
                child: Container(height: 2, color: pagado ? AppColors.success : AppColors.border),
              );
            }
            final idx = i ~/ 2;
            return _HitoPlan(hito: _hitos[idx]);
          }),
        ),
      ],
    );
  }
}

class _HitoData {
  const _HitoData(this.label, this.monto, this.estado, this.pagado);
  final String label;
  final String monto;
  final String estado;
  final bool pagado;
}

class _HitoPlan extends StatelessWidget {
  const _HitoPlan({required this.hito});
  final _HitoData hito;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: hito.pagado ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: hito.pagado ? AppColors.success : AppColors.border,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: hito.pagado
              ? const Icon(AppIcons.check, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 2),
        Text(hito.label, style: AppTextStyles.labelSmall.copyWith(fontSize: 8)),
        Text(hito.monto,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 7, fontWeight: AppTextStyles.weightBold)),
        Text(hito.estado,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 7,
              color: hito.pagado ? AppColors.success : AppColors.textSecondary,
            )),
      ],
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

class _CardCartera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)],
      ),
      child: const Icon(AppIcons.receipt, size: AppSizing.iconMd, color: AppColors.primary),
    );
  }
}
