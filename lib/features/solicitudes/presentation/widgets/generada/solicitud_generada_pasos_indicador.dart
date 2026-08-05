// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_pasos_indicador.dart
//
// Indicador horizontal de los 4 pasos del flujo post-generación (Completar
// ficha → Validar ficha → Adjuntar docs → Enviar a cobranza), usado por
// SolicitudGeneradaView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class PasosGeneradaIndicador extends StatelessWidget {
  final int pasoActual;

  const PasosGeneradaIndicador({super.key, required this.pasoActual});

  static const _pasos = [
    'Completar ficha',
    'Validar ficha',
    'Adjuntar docs',
    'Enviar a cobranza',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                                    ? AppColors.purple
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
                              : ((i + 1) < pasoActual
                                    ? AppColors.purple
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
                      fontSize: 9,
                      fontWeight: (i + 1) == pasoActual
                          ? AppTextStyles.weightBold
                          : AppTextStyles.weightRegular,
                      color: (i + 1) == pasoActual
                          ? AppColors.purple
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
    if (completado) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check, size: 16, color: AppColors.textOnDark),
        ),
      );
    }

    if (activo) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.purple,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$numero',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$numero',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
