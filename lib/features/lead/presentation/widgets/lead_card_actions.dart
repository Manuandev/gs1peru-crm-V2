// lib/features/lead/presentation/widgets/lead_card_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Fila de botones de acción que aparece en la parte inferior de cada LeadCard.
/// Los callbacks los inyecta el padre con la lógica real.
class LeadCardActions extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onStarTap;

  const LeadCardActions({
    super.key,
    required this.lead,
    this.onWhatsAppTap,
    this.onChatTap,
    this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // _LeadActionButton(
        //   icon: AppIconsSocial.whatsapp,
        //   color: Color(0xFF25D366),
        //   onTap: onWhatsAppTap,
        // ),
        // const SizedBox(width: AppSpacing.md),
        if (lead.ibChat) ...[
          _LeadActionButton(
            icon: AppIcons.chat,
            color: AppColors.primary,
            onTap: onChatTap,
          ),
        ],
        const SizedBox(width: AppSpacing.md),
        _LeadActionButton(
          icon: lead.isFavorito ? AppIcons.starFilled : AppIcons.star,
          color: lead.isFavorito ? AppColors.favorito : AppColors.textDisabled,
          onTap: onStarTap,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón individual circular con fondo suave
// ─────────────────────────────────────────────────────────────────────────────

class _LeadActionButton extends StatelessWidget {
  final dynamic icon; // IconData (Material) o IconDataBrands (FontAwesome)
  final Color color;
  final VoidCallback? onTap;

  const _LeadActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppSizing.buttonHeightSmall,
        height: AppSizing.buttonHeightSmall,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: icon is IconData
            ? Icon(icon as IconData, size: AppSizing.iconSearch, color: color)
            : FaIcon(icon, size: AppSizing.iconSm, color: color),
      ),
    );
  }
}
