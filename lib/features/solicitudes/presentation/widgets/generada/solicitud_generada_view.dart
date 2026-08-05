// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudGeneradaView extends StatelessWidget {
  final Solicitud solicitud;
  final String comprobante;

  const SolicitudGeneradaView({
    super.key,
    required this.solicitud,
    this.comprobante = '',
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      // Sin botón de retroceso — esta pantalla es un punto final del flujo
      // de generar solicitud, no tiene sentido volver al wizard. El back
      // del celular (gesto/botón físico) sigue intentando hacer pop, pero
      // onPop lo intercepta y manda a la lista de solicitudes en vez de
      // dejarlo hacer pop normal.
      onPop: () => context.goToSolicitudes(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Solicitud lista',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          Text(
            'Tu solicitud ha sido generada y está en proceso de validación',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white(0.75),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Indicador de pasos bajo el header ─────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: PasosGeneradaIndicador(pasoActual: 4),
          ),

          // ── Contenido scrollable ───────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  const MensajeExito(),
                  const SizedBox(height: AppSpacing.sm),
                  CardInfoSolicitud(
                    solicitud: solicitud,
                    comprobante: comprobante,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const ListaVerificacion(),
                  const SizedBox(height: AppSpacing.sm),
                  const TipProximoPaso(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // ── Botones fijos al pie ───────────────────────────────
          BotonesFooter(solicitud: solicitud),
        ],
      ),
    );
  }
}
