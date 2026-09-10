// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_participantes_resumen.dart
//
// Card de resumen de inversión (Inversión/IGV/Importe total) al pie de
// SolicitudParticipantesView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class ResumenInversion extends StatelessWidget {
  // Inversión/IGV/Importe total ya calculados por calcularTotalesSolicitud()
  // (solicitud_guardar_helper.dart) — el mismo cálculo que usan el Resumen
  // (paso 4) y el guardado, así los 3 muestran/guardan siempre lo mismo.
  // Antes este widget recalculaba por su cuenta (precio pactado de la
  // negociación si la solicitud estaba completa, si no Inversión + IGV) —
  // en una solicitud ya guardada eso pisaba los montos reales con el precio
  // ACTUAL de la negociación (bug real 2026-09-10, ver ese helper).
  final TotalesSolicitud totales;
  final double igvPorcentaje;
  // Símbolo de la moneda fijada por la negociación de origen (ver
  // SolicitudFormState.idMonedaBloqueada) — null si esta solicitud no viene
  // de una negociación o el catálogo aún no la resuelve; en ese caso se
  // muestra el ícono genérico de siempre en vez del símbolo.
  final String? monedaSimbolo;

  const ResumenInversion({
    super.key,
    required this.totales,
    required this.igvPorcentaje,
    this.monedaSimbolo,
  });

  @override
  Widget build(BuildContext context) {
    final igvLabel = igvPorcentaje % 1 == 0
        ? igvPorcentaje.toInt().toString()
        : igvPorcentaje.toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.ui1,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.ui3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.ui2,
                shape: BoxShape.circle,
              ),
              child: (monedaSimbolo != null && monedaSimbolo!.isNotEmpty)
                  ? Center(
                      child: Text(
                        monedaSimbolo!,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    )
                  : const Icon(
                      AppIcons.pieChart,
                      color: AppColors.primary,
                      size: AppSizing.iconMd,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _FilaMonto(
                  label: 'Inversión',
                  monto: totales.inversion,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'IGV ($igvLabel%)',
                  monto: totales.igv,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'Importe total',
                  monto: totales.importeTotal,
                  negrita: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _FilaMonto extends StatelessWidget {
  final String label;
  final double monto;
  final bool negrita;

  const _FilaMonto({
    required this.label,
    required this.monto,
    required this.negrita,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textPrimary,
      fontWeight: negrita
          ? AppTextStyles.weightBold
          : AppTextStyles.weightRegular,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: estilo),
          Text(NumberFormatUtils.formatMonto(monto), style: estilo),
        ],
      ),
    );
  }
}
