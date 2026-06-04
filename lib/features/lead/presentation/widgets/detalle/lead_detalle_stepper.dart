// lib/features/lead/presentation/widgets/detalle/lead_detalle_stepper.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class LeadDetalleStepper extends StatelessWidget {
  final String idEstadoActual;
  const LeadDetalleStepper({super.key, required this.idEstadoActual});

  static const _pasos = [
    _DatoPaso(id: '00', label: 'Nuevo', icon: AppIconsSocial.etapaNuevo),
    _DatoPaso(
      id: '01',
      label: 'En desarrollo',
      icon: AppIconsSocial.etapaEnDesarrollo,
    ),
    _DatoPaso(
      id: '02',
      label: 'Propuesta',
      icon: AppIconsSocial.etapaPropuesta,
    ),
    _DatoPaso(id: '11', label: 'Cobranza', icon: AppIconsSocial.etapaGanado),
  ];

  int get _indiceActual {
    final idx = _pasos.indexWhere((p) => p.id == idEstadoActual);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final actual = _indiceActual;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
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
            if (i < _pasos.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm2),
                child: Icon(
                  AppIcons.forward,
                  size: AppSizing.iconSm,
                  color: AppColors.textDisabled,
                ),
              ),
          ],
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
    final colorEstado = AppIconsSocial.colorEstado(paso.id);
    final Color bgCircle;
    final Color iconColor;
    final Color borderColor;

    if (isActivo) {
      bgCircle = colorEstado;
      iconColor = AppColors.textOnDark;
      borderColor = colorEstado;
    } else if (isCompletado) {
      bgCircle = AppIconsSocial.bgEstado(paso.id);
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
