// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_pie.dart
//
// Elementos de cierre de SolicitudGeneradaView: el tip informativo de
// "Próximo paso" (último ítem del contenido scrollable) y los botones fijos
// al pie ("Volver a solicitudes" / "Enviar a cobranzas").

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class TipProximoPaso extends StatelessWidget {
  const TipProximoPaso({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_add,
              color: AppColors.textOnDark,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo paso',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Esta solicitud será enviada a Cobranzas, donde se encargará de ',
                      ),
                      TextSpan(
                        text: 'facturar y realizar el seguimiento de pago.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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

class BotonesFooter extends StatelessWidget {
  final Solicitud solicitud;

  const BotonesFooter({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Volver a solicitudes
          Expanded(
            child: CustomOutlinedButton(
              text: 'Volver a solicitudes',
              icon: Icons.chevron_left,
              foregroundColor: AppColors.textSecondary,
              borderColor: AppColors.border,
              borderWidth: 1.5,
              height: AppSizing.buttonHeight,
              onPressed: () => context.goToSolicitudes(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Enviar a cobranzas
          Expanded(
            child: CustomPrimaryButton(
              text: 'Enviar a cobranzas',
              icon: Icons.send,
              backgroundColor: AppColors.purple,
              onPressed: () async {
                final confirmado = await context.showConfirmDialog(
                  title: 'Enviar a cobranzas',
                  message:
                      '¿Estás seguro que deseas enviar esta solicitud a cobranzas?',
                  confirmText: 'Enviar',
                  cancelText: 'Cancelar',
                );
                if (confirmado && context.mounted) context.goToCobranza();
              },
            ),
          ),
        ],
      ),
    );
  }
}
