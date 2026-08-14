// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_resumen_comercial.dart
//
// Sección "Resumen comercial" (Inversión/IGV/Importe total) de
// SolicitudResumenView.

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionResumenComercial extends StatelessWidget {
  const SeccionResumenComercial({super.key});

  @override
  Widget build(BuildContext context) {
    // Desde el 2026-07-16 cada importe de participante ya es la BASE sin
    // IGV (ver _importeFijo en solicitud_participantes_view.dart), así que
    // la suma de importes ES la inversión directamente — el IGV se SUMA
    // encima para el importe total (revierte el fix del 2026-07-14, donde
    // el importe venía con IGV incluido y había que extraerlo). Desde el
    // 2026-07-17 la suma es solo de participantes Pagantes — un Invitado no
    // paga, ver ParticipantesState.totalPagantes.
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposParticipante = catalogState is CatalogsLoaded
        ? catalogState.tiposParticipante
        : const <TipoParticipanteItem>[];
    final participantesState = context.watch<ParticipantesCubit>().state;
    final inversion = participantesState.totalPagantes(tiposParticipante);
    final igvPorcentaje = catalogState is CatalogsLoaded
        ? catalogState.igvPorcentaje
        : 0.0;
    final formState = context.watch<SolicitudFormCubit>().state;
    final cantidadEsperada = formState.cantidadEsperada;
    final completo =
        cantidadEsperada != null &&
        cantidadEsperada > 0 &&
        participantesState.participantes.length >= cantidadEsperada &&
        formState.precioTotalLead > 0;

    double importeTotal;
    if (completo) {
      // Solicitud completa (todos los participantes esperados agregados) y
      // viniendo de una negociación con precio ya pactado — "Importe total"
      // se fija DIRECTO en ese precio, no se recalcula con
      // `inversion × igv%` — mismo fix que ResumenInversion
      // (solicitud_participantes_resumen.dart, paso 2, 2026-08-14): ese
      // cálculo puede caer justo en un empate de redondeo (ej. inversión
      // 5084.75 al 18% cae en 6000.005 exacto) que según el punto flotante
      // sube a 6000.01 en vez de calzar contra los 6000.00 pactados. El IGV
      // de abajo sale de restarle la Inversión a este total ya fijo — el
      // centavo de diferencia se absorbe siempre ahí, nunca en la
      // Inversión ni en el precio pactado.
      importeTotal = formState.precioTotalLead;
    } else {
      // Todavía no está completa (o no viene de una negociación) — sin un
      // precio pactado contra el cual fijar el total, se arma con el
      // cálculo normal: IGV redondeado sobre el total, no por separado.
      final igvSinRedondear = inversion * igvPorcentaje / 100;
      importeTotal = double.parse(
        (inversion + igvSinRedondear).toStringAsFixed(2),
      );
    }
    final igv = double.parse((importeTotal - inversion).toStringAsFixed(2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CabeceraSeccion(
          icono: AppIcons.moneda,
          titulo: 'Resumen comercial',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Inversion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inversion',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    NumberFormatUtils.formatMonto(inversion),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            // IGV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGV',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    NumberFormatUtils.formatMonto(igv),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            // Importe total
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Importe total',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      NumberFormatUtils.formatMonto(importeTotal),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
