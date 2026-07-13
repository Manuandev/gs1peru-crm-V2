// lib/features/cobranza/presentation/widgets/plan/cobranza_plan_configurar_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Card de configuración de una cuota ya seleccionada del cronograma (tap en
/// una fila). N° cuota es de solo lectura; Días y Fecha son los únicos
/// campos editables. "Modificar" aplica los cambios solo a esa cuota.
class CobranzaPlanConfigurarCard extends StatelessWidget {
  final CobranzaPlanState state;
  final TextEditingController diasCtrl;
  final TextEditingController fechaCtrl;
  final VoidCallback onFechaTap;

  const CobranzaPlanConfigurarCard({
    super.key,
    required this.state,
    required this.diasCtrl,
    required this.fechaCtrl,
    required this.onFechaTap,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CobranzaPlanBloc>();
    final estaCargando = state.status == CobranzaPlanStatus.loading;
    final haySeleccion = state.formNumeroCuota != 0;

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
          const SizedBox(height: AppSpacing.xs),
          if (!haySeleccion)
            Text(
              'Toca una cuota del cronograma para editarla.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // N° cuota — solo lectura, mismo CustomTextField que los demás
              // para garantizar el mismo alto/estilo (antes era un Container
              // aparte que se veía de otro tamaño)
              Expanded(
                child: CustomTextField(
                  label: 'N° cuota',
                  enabled: false,
                  controller: TextEditingController(
                    text: haySeleccion ? '${state.formNumeroCuota}' : '—',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Días
              Expanded(
                child: CustomTextField(
                  label: 'Días',
                  controller: diasCtrl,
                  enabled: haySeleccion,
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
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Fecha venc.',
                  controller: fechaCtrl,
                  readOnly: true,
                  enabled: haySeleccion,
                  suffixIcon: const Icon(AppIcons.calendar),
                  onTap: haySeleccion ? onFechaTap : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomPrimaryButton(
            text: 'Modificar',
            isEnabled: haySeleccion,
            onPressed: estaCargando
                ? null
                : () => bloc.add(const ModificarCuotaPressed()),
          ),
        ],
      ),
    );
  }
}
