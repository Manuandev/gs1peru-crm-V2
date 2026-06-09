// lib/features/cobranza/presentation/widgets/cobranza_plan_configurar_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Card de configuración de una cuota: N°, Días, Fecha, Importe + acciones.
class CobranzaPlanConfigurarCard extends StatelessWidget {
  final CobranzaPlanState state;
  final TextEditingController numCuotaCtrl;
  final TextEditingController diasCtrl;
  final TextEditingController fechaCtrl;
  final TextEditingController montoCtrl;
  final VoidCallback onFechaTap;

  const CobranzaPlanConfigurarCard({
    super.key,
    required this.state,
    required this.numCuotaCtrl,
    required this.diasCtrl,
    required this.fechaCtrl,
    required this.montoCtrl,
    required this.onFechaTap,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CobranzaPlanBloc>();
    final estaCargando = state.status == CobranzaPlanStatus.loading;

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
          Text(
            'Configurar cuota',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ── Fila de 4 inputs ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // N° cuota
              Flexible(
                child: CustomTextField(
                  label: 'N° cuota',
                  controller: numCuotaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) {
                      bloc.add(NumeroCuotaChanged(n));
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Días
              Flexible(
                child: CustomTextField(
                  label: 'Días',
                  controller: diasCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final d = int.tryParse(v);
                    if (d != null && d > 0) {
                      bloc.add(DiasChanged(d));
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Fecha vencimiento
              Flexible(
                flex: 2,
                child: CustomTextField(
                  label: 'Fecha venc.',
                  controller: fechaCtrl,
                  readOnly: true,
                  suffixIcon: const Icon(AppIcons.calendar),
                  onTap: onFechaTap,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Importe
              Flexible(
                flex: 2,
                child: CustomTextField(
                  label: 'Importe',
                  controller: montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (v) {
                    final m = double.tryParse(v);
                    if (m != null && m >= 0) {
                      bloc.add(MontoCuotaChanged(m));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // ── Botones de acción ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: CustomPrimaryButton(
                  text: 'Vista previa',
                  onPressed: estaCargando
                      ? null
                      : () => bloc.add(const VistaPreviaPressed()),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomSecondaryButton(
                  text: 'Limpiar',
                  onPressed: estaCargando
                      ? null
                      : () => bloc.add(const LimpiarPressed()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
