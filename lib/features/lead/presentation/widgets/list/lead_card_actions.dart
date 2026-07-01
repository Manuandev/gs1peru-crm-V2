// lib/features/lead/presentation/widgets/list/lead_card_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Fila de botones de acción que aparece en la parte inferior de cada LeadCard.
/// Los callbacks los inyecta el padre con la lógica real.
class LeadCardActions extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onVerDetalleTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onStarTap;

  const LeadCardActions({
    super.key,
    required this.lead,
    this.onWhatsAppTap,
    this.onVerDetalleTap,
    this.onChatTap,
    this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorWhatsApp = AppSocialUtils.colorCanalById(1);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onWhatsAppTap,
            child: Container(
              height: AppSizing.buttonHeightSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorWhatsApp,
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: FaIcon(
                AppIcons.whatsapp,
                size: AppSizing.iconActionSm,
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onVerDetalleTap,
            child: Container(
              height: AppSizing.buttonHeightSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Ver detalle',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<String>(
          tooltip: 'Más opciones',
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusLg),
          ),
          onSelected: (value) {
            switch (value) {
              case 'favorito':
                onStarTap?.call();
              case 'chat':
                onChatTap?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorito',
              child: Row(
                children: [
                  Icon(
                    lead.isFavorito ? AppIcons.starFilled : AppIcons.star,
                    size: AppSizing.iconNav,
                    color: lead.isFavorito
                        ? AppColors.favorito
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    lead.isFavorito ? 'Quitar de favoritos' : 'Marcar favorito',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            if (lead.tieneConversacionAbierta == true)
              PopupMenuItem(
                value: 'chat',
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.chat,
                      size: AppSizing.iconNav,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Abrir chat', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
          ],
          child: Container(
            width: AppSizing.buttonHeightSmall,
            height: AppSizing.buttonHeightSmall,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              AppIcons.more,
              size: AppSizing.iconActionSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
