// lib/features/lead/presentation/widgets/list/lead_card_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// Botones de acción de LeadCard: WhatsApp (ícono, chico y verde) y "Ver
/// detalle" (chico, borde y texto azules), en fila. Los callbacks los
/// inyecta el padre.
class LeadCardActions extends StatelessWidget {
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onVerDetalleTap;

  const LeadCardActions({
    super.key,
    this.onWhatsAppTap,
    this.onVerDetalleTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorWhatsApp = AppSocialUtils.colorCanal('whatsapp');
    final colorPrimary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onWhatsAppTap,
          child: Container(
            width: AppSizing.miniActionButton,
            height: AppSizing.miniActionButton,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorWhatsApp,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            child: FaIcon(
              AppIcons.whatsapp,
              size: AppSizing.iconSm,
              color: AppColors.textOnDark,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: onVerDetalleTap,
          child: Container(
            height: AppSizing.miniActionButton,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: colorPrimary),
            ),
            child: Text(
              'Ver detalle',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorPrimary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
