// lib/features/home/presentation/widgets/dashboard/dashboard_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';

class DashboardCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? badge;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── CARD ────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── BADGE ────────────────────────────────────────────
          if (badge != null && badge! > 0)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// La estructura de archivos queda así:
// ```
// home/presentation/widgets/
// ├── home_view.dart
// ├── home_portrait.dart       ← nuevo
// ├── home_landscape.dart      ← nuevo
// └── dashboard/
//     ├── dashboard_card.dart  ← nuevo
//     ├── home_menu_cards.dart ← nuevo
//     ├── leads_section.dart   ← tú lo armas con tus LeadItem
//     └── recordatorios_section.dart ← ídem