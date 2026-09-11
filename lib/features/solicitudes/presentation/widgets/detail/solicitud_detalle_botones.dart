// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_botones.dart
//
// Botones de acción fijos al pie de SolicitudDetalleView
// ("Editar ficha"/"Validar" + "Revisar solicitud").

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class BotonesDetalle extends StatelessWidget {
  final Solicitud solicitud;
  // true si se entró desde el botón "Validar" de la card — en ese caso el
  // botón de editar SIEMPRE se muestra (con el texto "Validar" en vez de
  // "Editar ficha", mismo mecanismo — abre el wizard en modoEdicion:true),
  // sin importar Solicitud.puedeEditar. Si se entró por "Ver", se sigue
  // usando puedeEditar (idEstado == 0) como antes.
  final bool origenValidar;

  const BotonesDetalle({
    super.key,
    required this.solicitud,
    this.origenValidar = false,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarEditar = origenValidar || solicitud.puedeEditar;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Botones custom del core: texto en UNA línea, centrado junto al
          // ícono (antes FilledButton/OutlinedButton nativos con el texto del
          // tema, que en pantallas angostas partía "Revisar solicitud" en 2
          // líneas). Padding horizontal reducido para que el texto quepa
          // completo con los 2 botones lado a lado.
          if (mostrarEditar) ...[
            Expanded(
              child: CustomOutlinedButton(
                text: origenValidar ? 'Validar' : 'Editar ficha',
                icon: AppIcons.edit,
                onPressed: () => context.goToFichaCompletarSolicitud(
                  solicitud: solicitud,
                  modoEdicion: true,
                ),
                height: AppSizing.buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                foregroundColor: AppColors.primary,
                borderColor: AppColors.border,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: CustomPrimaryButton(
              text: 'Revisar solicitud',
              icon: AppIcons.visibility,
              onPressed: () => context.goToFichaCompletarSolicitud(
                solicitud: solicitud,
                modoEdicion: false,
              ),
              height: AppSizing.buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
          ),
        ],
      ),
    );
  }
}
