// lib/features/cobranza/presentation/widgets/plan/cobranza_plan_resumen_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Card con los totales del plan de crédito: 3 celdas de solo lectura
/// (Importe comprobante / Detracción / Importe a crédito) + "¿En cuántas
/// cuotas?" editable, que dispara la regeneración del cronograma. Las 4
/// usan CustomTextField (las de solo lectura con enabled:false) para
/// garantizar el mismo tamaño exacto en las 4 — no un Container aparte
/// intentando adivinar la altura del campo editable.
class CobranzaPlanResumenCard extends StatelessWidget {
  final CobranzaPlanState state;
  final TextEditingController numCuotasCtrl;
  const CobranzaPlanResumenCard({
    super.key,
    required this.state,
    required this.numCuotasCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan de crédito',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Importe Comprobante',
                  enabled: false,
                  controller: TextEditingController(
                    text: state.montoTotal.toStringAsFixed(2),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label: 'Detracción (12%)',
                  enabled: false,
                  controller: TextEditingController(
                    text: state.detraccion.toStringAsFixed(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Importe a Crédito menos Detracción',
                  enabled: false,
                  controller: TextEditingController(
                    text: state.importeCredito.toStringAsFixed(2),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label: '¿En cuántas cuotas?',
                  controller: numCuotasCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) {
                      context.read<CobranzaPlanBloc>().add(
                        NumCuotasDeseadasChanged(n),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
