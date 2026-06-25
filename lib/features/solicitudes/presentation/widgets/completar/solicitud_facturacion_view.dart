// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

class SolicitudFacturacionView extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudFacturacionView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud de inscripción',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      appBarTrailingButtons: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.white(0.15),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Text(
              'Paso 3 de 4',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
      body: const Column(
        children: [
          SolicitudPasosIndicador(pasoActual: 3),
        ],
      ),
    );
  }
}
