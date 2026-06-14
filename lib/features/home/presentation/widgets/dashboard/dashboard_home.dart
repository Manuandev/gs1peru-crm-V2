// lib/features/home/presentation/widgets/dashboard/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class DashboardCard extends StatelessWidget {
  final String label;
  final dynamic icon;
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
    final badgeBg = ColorUtils.badgeColor(color);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        child: Stack(
          children: [
            // ── CARD ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: AppColors.opacityShadow),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── ÍCONO ──────────────────────────────────────
                  icon is IconData
                      ? Icon(
                          icon as IconData,
                          color: textColor,
                          size: AppSizing.iconLg,
                        )
                      : FaIcon(
                          icon as FaIconData,
                          color: textColor,
                          size: AppSizing.iconFaLg,
                        ),
                  const SizedBox(width: AppSpacing.sm),
                  // ── LABEL ──────────────────────────────────────
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textColor,
                        fontWeight: AppTextStyles.weightBold,
                        letterSpacing: AppTextStyles.letterSpacingXNarrow,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            // ── BADGE: esquina superior derecha, dentro del card ──
            if (badge != null && badge! > 0)
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: AppSizing.iconMd,
                    minHeight: AppSizing.iconActionSm,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.chipGap,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(
                      AppSizing.radiusCircular,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
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
