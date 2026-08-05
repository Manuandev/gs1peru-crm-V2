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
          if (mostrarEditar) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.goToFichaCompletarSolicitud(
                  solicitud: solicitud,
                  modoEdicion: true,
                ),
                icon: const Icon(AppIcons.edit, size: AppSizing.iconActionSm),
                label: Text(origenValidar ? 'Validar' : 'Editar ficha'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context.goToFichaCompletarSolicitud(
                solicitud: solicitud,
                modoEdicion: false,
              ),
              icon: const Icon(
                AppIcons.visibility,
                size: AppSizing.iconActionSm,
              ),
              label: const Text('Revisar solicitud'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
                minimumSize: const Size.fromHeight(AppSizing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
