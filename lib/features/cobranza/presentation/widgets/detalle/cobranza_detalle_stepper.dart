// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_stepper.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class CobranzaDetalleStepper extends StatelessWidget {
  final String idEstadoActual;
  const CobranzaDetalleStepper({super.key, required this.idEstadoActual});

  static const _pasos = [
    _PasoDef(id: 'PD', label: 'Pend.\ndocumento', icono: AppIcons.fileOutlined),
    _PasoDef(id: 'F', label: 'Facturar', icono: AppIcons.receipt),
    _PasoDef(id: 'PP', label: 'Pend. pago', icono: AppIcons.time),
    _PasoDef(id: 'CA', label: 'Cancelado', icono: AppIcons.checkCircle),
  ];

  static const _orden = ['PD', 'F', 'PP', 'CA'];

  @override
  Widget build(BuildContext context) {
    final indiceActual = _orden.indexOf(idEstadoActual);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
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
        children: List.generate(_pasos.length, (i) {
          final paso = _pasos[i];
          final esActivo = i == indiceActual;
          final esCompletado = i < indiceActual;
          final esUltimo = i == _pasos.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _PasoItem(
                    paso: paso,
                    esActivo: esActivo,
                    esCompletado: esCompletado,
                  ),
                ),
                if (!esUltimo)
                  _Linea(completada: esCompletado || esActivo),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PasoItem extends StatelessWidget {
  final _PasoDef paso;
  final bool esActivo;
  final bool esCompletado;

  const _PasoItem({
    required this.paso,
    required this.esActivo,
    required this.esCompletado,
  });

  @override
  Widget build(BuildContext context) {
    final color = esActivo
        ? AppColors.warning
        : esCompletado
            ? AppColors.primary
            : AppColors.border;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizing.avatarSm,
          height: AppSizing.avatarSm,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: esActivo
                ? AppColors.warning.withValues(alpha: 0.1)
                : esCompletado
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.transparent,
            border: Border.all(color: color, width: AppSizing.borderWidthThin * 2),
          ),
          child: Icon(
            paso.icono,
            size: AppSizing.iconSm,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          paso.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: esActivo
                ? AppColors.warning
                : esCompletado
                    ? AppColors.primary
                    : AppColors.textDisabled,
            fontWeight: esActivo
                ? AppTextStyles.weightSemiBold
                : AppTextStyles.weightRegular,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _Linea extends StatelessWidget {
  final bool completada;
  const _Linea({required this.completada});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizing.borderWidthThin * 2,
      width: AppSpacing.lg,
      color: completada ? AppColors.primary : AppColors.border,
    );
  }
}

class _PasoDef {
  final String id;
  final String label;
  final IconData icono;
  const _PasoDef({required this.id, required this.label, required this.icono});
}
