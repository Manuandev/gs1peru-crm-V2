// lib/features/cobranza/presentation/widgets/cobranza_resumen_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Siempre visible. Anima el contenido cuando cambia la condición de pago.
class CobranzaResumenCard extends StatelessWidget {
  final CobranzaFacturaState state;
  const CobranzaResumenCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Resumen calculado ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: state.esCredito
                ? _ResumenCredito(key: const ValueKey('cr'), state: state)
                : _ResumenContado(key: const ValueKey('co'), state: state),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ── Aviso informativo ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.infoCircle,
                size: AppSizing.iconMd,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  state.esCredito
                      ? 'Antes de facturar, valida el plan de crédito.'
                      : 'Completa los datos para continuar con la facturación.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumen Crédito — ícono + título primary + filas
// ─────────────────────────────────────────────────────────────────────────────

class _ResumenCredito extends StatelessWidget {
  final CobranzaFacturaState state;
  const _ResumenCredito({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: AppSizing.buttonHeightSmall,
              height: AppSizing.buttonHeightSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryWithOpacity(0.08),
              ),
              child: Icon(
                AppIcons.pieChart,
                size: AppSizing.iconSm,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Resumen crédito',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _FilaResumen(
          label: 'Importe comprobante',
          valor: 'S/ ${state.montoTotal.toStringAsFixed(2)}',
        ),
        _FilaResumen(
          label: 'Detracción 12%',
          valor: 'S/ ${state.detraccion.toStringAsFixed(2)}',
        ),
        _FilaResumen(
          label: 'Importe a crédito',
          valor: 'S/ ${state.importeCredito.toStringAsFixed(2)}',
          destacado: true,
        ),
        _FilaResumen(label: 'N° cuotas', valor: '${state.numCuotas}'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumen Contado — título + filas
// ─────────────────────────────────────────────────────────────────────────────

class _ResumenContado extends StatelessWidget {
  final CobranzaFacturaState state;
  const _ResumenContado({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista previa del cobro',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _FilaResumen(
          label: 'Total curso',
          valor: 'S/ ${state.montoTotal.toStringAsFixed(2)}',
        ),
        _FilaResumen(
          label: 'Pago a cuenta',
          valor: 'S/ ${state.pagoACuenta.toStringAsFixed(2)}',
        ),
        _FilaResumen(
          label: 'Saldo',
          valor: 'S/ ${state.saldo.toStringAsFixed(2)}',
          destacado: true,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilaResumen extends StatelessWidget {
  final String label;
  final String valor;
  final bool destacado;

  const _FilaResumen({
    required this.label,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: destacado
                ? AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  )
                : AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            valor,
            style: destacado
                ? AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTextStyles.weightBold,
                  )
                : AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
