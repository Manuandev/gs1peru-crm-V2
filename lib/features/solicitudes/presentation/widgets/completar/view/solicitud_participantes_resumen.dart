// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_participantes_resumen.dart
//
// Card de resumen de inversión (Inversión/IGV/Importe total) al pie de
// SolicitudParticipantesView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class ResumenInversion extends StatelessWidget {
  // Suma de los importes de participantes PAGANTES únicamente (ver
  // ParticipantesState.totalPagantes — los Invitados no se cuentan, aunque
  // tengan su propio importe puesto, 2026-07-17). Desde el 2026-07-16 cada
  // importe ya es la BASE sin IGV (ver _importeFijo), así que `total` acá
  // ES la inversión directamente. El IGV se SUMA encima para el importe
  // total — revierte el fix del 2026-07-14 (donde el importe venía con IGV
  // incluido y había que extraerlo); con la nueva definición del importe,
  // sumar es lo correcto.
  final double total;
  final double igvPorcentaje;
  // Símbolo de la moneda fijada por la negociación de origen (ver
  // SolicitudFormState.idMonedaBloqueada) — null si esta solicitud no viene
  // de una negociación o el catálogo aún no la resuelve; en ese caso se
  // muestra el ícono genérico de siempre en vez del símbolo.
  final String? monedaSimbolo;

  const ResumenInversion({
    super.key,
    required this.total,
    required this.igvPorcentaje,
    this.monedaSimbolo,
  });

  @override
  Widget build(BuildContext context) {
    final inversion = total;
    final igv = inversion * igvPorcentaje / 100;
    final importeTotal = inversion + igv;
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
                  monto: inversion,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'IGV ($igvLabel%)',
                  monto: igv,
                  negrita: false,
                ),
                const Divider(height: 1, thickness: 0.5),
                _FilaMonto(
                  label: 'Importe total',
                  monto: importeTotal,
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
          Text(monto.toStringAsFixed(2), style: estilo),
        ],
      ),
    );
  }
}
