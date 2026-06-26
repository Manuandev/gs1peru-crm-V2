// lib/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class SolicitudPasosIndicador extends StatelessWidget {
  final int pasoActual;

  const SolicitudPasosIndicador({super.key, required this.pasoActual});

  static const _pasos = [
    'Solicitante',
    'Participantes',
    'Facturación',
    'Resumen',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (int i = 0; i < _pasos.length; i++)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: i == 0
                              ? Colors.transparent
                              : (i <= pasoActual - 1
                                    ? AppColors.primary
                                    : AppColors.border),
                        ),
                      ),
                      _CirculoPaso(
                        numero: i + 1,
                        activo: (i + 1) == pasoActual,
                        completado: (i + 1) < pasoActual,
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: i == _pasos.length - 1
                              ? Colors.transparent
                              : ((i + 1) <= pasoActual - 1
                                    ? AppColors.primary
                                    : AppColors.border),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (int i = 0; i < _pasos.length; i++)
                Expanded(
                  child: Text(
                    _pasos[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightBold
                          : AppTextStyles.weightRegular,
                      color: (i + 1) == pasoActual
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
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
      width: 28,
      height: 28,
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
          style: TextStyle(
            fontSize: 11,
            color: destacado ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
      ),
    );
  }
}
