// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_stepper.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class CobranzaDetalleStepper extends StatelessWidget {
  // ID_ESTADO_GES crudo (DBO.[edu.TIP_ESTADO_GES]): 0=Pend.deDocumento
  // 2=Facturar 5=Pend.factura 3=Cancelado. 1=FreePass y 4=Anulado no forman
  // parte de este flujo de 4 etapas (indexOf devuelve -1 → ningún paso activo).
  final int idEstadoActual;
  const CobranzaDetalleStepper({super.key, required this.idEstadoActual});

  static const _pasos = [
    _PasoDef(id: 0, label: 'Pend.\ndocumento', icono: AppIcons.fileOutlined),
    _PasoDef(id: 2, label: 'Facturar', icono: AppIcons.receipt),
    _PasoDef(id: 5, label: 'Pend. pago', icono: AppIcons.time),
    _PasoDef(id: 3, label: 'Cancelado', icono: AppIcons.checkCircle),
  ];

  static const _orden = [0, 2, 5, 3];

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
      // Círculos+líneas y labels van en filas separadas: así el alto variable
      // de cada label (1 o 2 líneas) nunca desalinea los círculos entre sí
      // (antes vivían en la misma Column por paso y el Row los centraba según
      // el paso más alto, corriendo los círculos de labels más cortas).
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_pasos.length, (i) {
              final esActivo = i == indiceActual;
              final esCompletado = i < indiceActual;
              final esUltimo = i == _pasos.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _Circulo(
                          paso: _pasos[i],
                          esActivo: esActivo,
                          esCompletado: esCompletado,
                        ),
                      ),
                    ),
                    if (!esUltimo) _Linea(completada: esCompletado || esActivo),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_pasos.length, (i) {
              final paso = _pasos[i];
              final esActivo = i == indiceActual;
              final esCompletado = i < indiceActual;

              return Expanded(
                child: Text(
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
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  final _PasoDef paso;
  final bool esActivo;
  final bool esCompletado;

  const _Circulo({
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

    return Container(
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
      child: Icon(paso.icono, size: AppSizing.iconSm, color: color),
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
  final int id;
  final String label;
  final IconData icono;
  const _PasoDef({required this.id, required this.label, required this.icono});
}
