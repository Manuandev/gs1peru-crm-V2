// lib/features/home/presentation/widgets/dashboard/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// Tarjeta de módulo con layout vertical para el dashboard del home.
///
/// Estructura visual:
/// ┌──────────────────── [badge] ─┐
/// │                              │
/// │         [ícono]              │
/// │                              │
/// │  Nombre           [›]        │
/// │  Descripción                 │
/// └──────────────────────────────┘
class DashboardCard extends StatelessWidget {
  final String label;
  final dynamic icon;
  final String? descripcion;
  final int? badge;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.label,
    required this.icon,
    this.descripcion,
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
            // ── CARD BASE ───────────────────────────────────────────
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: AppSizing.dashListCardHeight,
              ),
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
              padding: const EdgeInsets.all(AppSpacing.sm2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      icon is IconData
                          ? Icon(
                              icon as IconData,
                              color: textColor,
                              size: AppSizing.iconLg,
                            )
                          : FaIcon(
                              icon as FaIconData,
                              color: textColor,
                              size: AppSizing.iconLg,
                            ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // ── NOMBRE + FLECHA ─────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: AppTextStyles.titleSmall2.copyWith(
                                color: textColor,
                                fontWeight: AppTextStyles.weightBold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (descripcion != null) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                descripcion!,
                                style: AppTextStyles.labelVerySmall8.copyWith(
                                  color: textColor.withValues(
                                    alpha: AppColors.opacityOnPrimarySubtle,
                                  ),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        AppIcons.forward,
                        color: textColor.withValues(
                          alpha: AppColors.opacityOnPrimarySubtle,
                        ),
                        size: AppSizing.iconActionSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── BADGE: esquina superior derecha ────────────────────
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
                      badge! > 99 ? '99+' : '$badge',
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
