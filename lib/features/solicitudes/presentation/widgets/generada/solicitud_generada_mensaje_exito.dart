// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_mensaje_exito.dart
//
// Card compacta "¡Listo!" con ícono animado de check + chispas decorativas,
// usada por SolicitudGeneradaView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class MensajeExito extends StatelessWidget {
  const MensajeExito({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(top: 4, left: 2, child: _Chispa()),
                const Positioned(bottom: 4, right: 2, child: _Chispa()),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textOnDark,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Listo!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Solicitud validada y lista para enviar a cobranzas.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chispa extends StatelessWidget {
  const _Chispa();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: 11,
      color: AppColors.success.withValues(alpha: 0.55),
    );
  }
}
