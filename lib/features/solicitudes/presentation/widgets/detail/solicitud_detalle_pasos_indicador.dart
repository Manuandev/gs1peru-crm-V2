// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_pasos_indicador.dart
//
// Indicador horizontal de los 4 pasos del flujo de una solicitud (Completar
// → Validar → Adjuntar → Cobranza), usado por SolicitudDetalleView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class PasosIndicador extends StatelessWidget {
  final int pasoActual;

  const PasosIndicador({super.key, required this.pasoActual});

  static const _etiquetas = ['Completar', 'Validar', 'Adjuntar', 'Cobranza'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _etiquetas.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Línea izquierda — transparente en el primer paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i > 0
                              ? (i <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                      _CirculoPaso(
                        numero: i + 1,
                        activo: (i + 1) == pasoActual,
                        completado: (i + 1) < pasoActual,
                      ),
                      // Línea derecha — transparente en el último paso
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _etiquetas.length - 1
                              ? ((i + 1) <= pasoActual
                                    ? AppColors.primary
                                    : AppColors.border)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _etiquetas[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: (i + 1) <= pasoActual
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CirculoPaso extends StatelessWidget {
  final int numero;
  final bool activo;
  final bool completado;

  const _CirculoPaso({
    required this.numero,
    required this.activo,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    final bool destacado = activo || completado;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: destacado ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: destacado ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$numero',
          style: AppTextStyles.labelSmall.copyWith(
            color: destacado ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
      ),
    );
  }
}
