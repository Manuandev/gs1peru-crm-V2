// lib/features/lead/presentation/widgets/detalle/lead_detalle_stepper.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class LeadDetalleStepper extends StatelessWidget {
  final String idEstadoActual;
  const LeadDetalleStepper({super.key, required this.idEstadoActual});

  static const _pasos = [
    _DatoPaso(id: '00', label: 'Nuevo', icon: AppIcons.etapaNuevo),
    _DatoPaso(
      id: '01',
      label: 'En desarrollo',
      icon: AppIcons.etapaEnDesarrollo,
    ),
    _DatoPaso(
      id: '02',
      label: 'Propuesta',
      icon: AppIcons.etapaPropuesta,
    ),
    _DatoPaso(id: '05', label: 'Cobranza', icon: AppIcons.etapaGanado),
  ];

  int get _indiceActual {
    final idx = _pasos.indexWhere((p) => p.id == idEstadoActual);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final actual = _indiceActual;
    final colorActual = AppSocialUtils.colorEstado(idEstadoActual);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ETAPA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${actual + 1} de ${_pasos.length} · ${_pasos[actual].label}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorActual,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _pasos.length; i++) ...[
                Expanded(
                  child: _PasoEtapa(
                    paso: _pasos[i],
                    isActivo: i == actual,
                    isCompletado: i < actual,
                  ),
                ),
                if (i < _pasos.length - 1) _Conector(completado: i < actual),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DatoPaso {
  final String id;
  final String label;
  final FaIconData icon;
  const _DatoPaso({required this.id, required this.label, required this.icon});
}

// Línea horizontal delgada que conecta dos nodos del stepper.
// El padding-top centra la línea con el centro del círculo de 40dp.
class _Conector extends StatelessWidget {
  final bool completado;
  const _Conector({required this.completado});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.md,
      child: Padding(
        padding: const EdgeInsets.only(
          top: (AppSizing.stepperCircleSize - AppSizing.hairline) / 2,
        ),
        child: Container(
          height: AppSizing.hairline,
          color: completado ? AppColors.success : AppColors.border,
        ),
      ),
    );
  }
}

class _PasoEtapa extends StatelessWidget {
  final _DatoPaso paso;
  final bool isActivo;
  final bool isCompletado;

  const _PasoEtapa({
    required this.paso,
    required this.isActivo,
    required this.isCompletado,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppSocialUtils.colorEstado(paso.id);
    final Color bgCircle;
    final Color iconColor;
    final Color borderColor;

    if (isActivo) {
      bgCircle = colorEstado;
      iconColor = AppColors.textOnDark;
      borderColor = colorEstado;
    } else if (isCompletado) {
      bgCircle = AppSocialUtils.bgEstado(paso.id);
      iconColor = colorEstado;
      borderColor = colorEstado;
    } else {
      bgCircle = AppColors.surface;
      iconColor = AppColors.textDisabled;
      borderColor = AppColors.border;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizing.stepperCircleSize,
          height: AppSizing.stepperCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgCircle,
            border: Border.all(
              color: borderColor,
              width: AppSizing.borderFocusWidth,
            ),
          ),
          child: Center(
            child: FaIcon(paso.icon, size: AppSizing.iconSm, color: iconColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          paso.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActivo || isCompletado
                ? colorEstado
                : AppColors.textDisabled,
            fontWeight: isActivo
                ? AppTextStyles.weightSemiBold
                : AppTextStyles.weightRegular,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}
