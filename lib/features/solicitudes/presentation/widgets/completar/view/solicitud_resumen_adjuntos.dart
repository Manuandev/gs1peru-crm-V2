// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_resumen_adjuntos.dart
//
// Sección "Documentos adjuntos" (voucher/O.C.) de SolicitudResumenView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionDocumentosAdjuntos extends StatelessWidget {
  final String voucherNombre;
  final String ocNombre;

  const SeccionDocumentosAdjuntos({
    super.key,
    required this.voucherNombre,
    required this.ocNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CabeceraSeccion(
          icono: AppIcons.attach,
          titulo: 'Documentos adjuntos',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TarjetaArchivo(
                icono: AppIcons.pdf,
                colorIcono: AppColors.brandForest,
                label: 'Voucher adjunto',
                nombreArchivo: voucherNombre,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TarjetaArchivo(
                icono: AppIcons.pdf,
                colorIcono: AppColors.brandRaspberryAccessible,
                label: 'O/C adjunta',
                nombreArchivo: ocNombre,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TarjetaArchivo extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String label;
  final String nombreArchivo;

  const _TarjetaArchivo({
    required this.icono,
    required this.colorIcono,
    required this.label,
    required this.nombreArchivo,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = nombreArchivo.isNotEmpty;
    final color = tieneArchivo ? colorIcono : AppColors.textDisabled;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizing.iconNav3,
            height: AppSizing.iconNav3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(icono, color: color, size: AppSizing.iconMd),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  tieneArchivo ? nombreArchivo : 'Sin adjuntar',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: tieneArchivo
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                    fontWeight: tieneArchivo
                        ? AppTextStyles.weightMedium
                        : AppTextStyles.weightRegular,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
