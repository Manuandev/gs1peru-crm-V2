// lib/features/lead/presentation/widgets/lead_card_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Fila de botones de acción que aparece en la parte inferior de cada LeadCard.
/// Los callbacks los inyecta el padre con la lógica real.
class LeadCardActions extends StatelessWidget {
  final LeadEntity lead;
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
        _LeadActionButton(
          icon: AppIconsSocial.whatsapp,
          color: Color(0xFF25D366),
          onTap: onWhatsAppTap,
        ),
        const SizedBox(width: AppSpacing.md),
        _LeadActionButton(
          icon: AppIcons.chat,
          color: AppColors.primary,
          onTap: onChatTap,
        ),
        const SizedBox(width: AppSpacing.md),
        _LeadActionButton(
          icon: Icons.star_border_rounded,
          color: Colors.amber,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        alignment: Alignment.center,
        child: icon is IconData
            ? Icon(icon as IconData, size: 20, color: color)
            : FaIcon(icon, size: 16, color: color),
      ),
    );
  }
}
