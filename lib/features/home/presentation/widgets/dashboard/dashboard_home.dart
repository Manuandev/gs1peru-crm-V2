// lib/features/home/presentation/widgets/dashboard/dashboard_card.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class DashboardCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int? badge;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.label,
    required this.icon,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromName(label);
    final textColor = ColorUtils.textColorOn(color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── CONTENIDO ──────────────────────────────────────
            Row(
              children: [
                // Ícono en círculo translúcido
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: textColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            // ── BADGE ──────────────────────────────────────────
            if (badge != null && badge! > 0)
              Positioned(
                top: -AppSpacing.md,
                right: -AppSpacing.sm,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
