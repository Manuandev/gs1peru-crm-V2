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
    // Mismo cálculo que el footer del paso 2 (ResumenInversion) y que el
    // guardado — ver calcularTotalesSolicitud() (solicitud_guardar_helper.
    // dart): en una solicitud ya guardada cuyo dinero no cambió muestra los
    // montos del backend tal cual (bug real 2026-09-10); si no, precio
    // pactado de la negociación (solicitud completa) o Inversión + IGV.
    final catalogState = context.watch<CatalogsBloc>().state;
    final totales = calcularTotalesSolicitud(
      formState: context.watch<SolicitudFormCubit>().state,
      participantesState: context.watch<ParticipantesCubit>().state,
      tiposParticipante: catalogState is CatalogsLoaded
          ? catalogState.tiposParticipante
          : const <TipoParticipanteItem>[],
      igvPorcentaje: catalogState is CatalogsLoaded
          ? catalogState.igvPorcentaje
          : 0.0,
    );

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
                    NumberFormatUtils.formatMonto(totales.inversion),
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
                    NumberFormatUtils.formatMonto(totales.igv),
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
                      NumberFormatUtils.formatMonto(totales.importeTotal),
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
