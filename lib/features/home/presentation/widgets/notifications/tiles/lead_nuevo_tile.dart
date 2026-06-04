// lib/features/home/presentation/widgets/notifications/tiles/lead_nuevo_tile.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class LeadNuevoTile extends StatelessWidget {
  final LeadNuevo lead;

  const LeadNuevoTile({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.chipGap,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lead.nombre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                  Text(
                    lead.fechaHora.formatConDia(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: AppColors.opacityHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              Text(
                lead.nombreEmpresa,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(
                    alpha: AppColors.opacityTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Icon(
                    AppIcons.phone,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      lead.telefono,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    AppIcons.user,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      lead.asignadoA,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              Wrap(
                spacing: AppSpacing.chipGap,
                runSpacing: AppSpacing.xs,
                children: [
                  _Tag(
                    label: lead.campania,
                    color: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                  ),
                  _Tag(
                    label: lead.evento,
                    color: colorScheme.secondaryContainer,
                    textColor: colorScheme.onSecondaryContainer,
                  ),
                  _Tag(
                    label: lead.canal,
                    color: colorScheme.tertiaryContainer,
                    textColor: colorScheme.onTertiaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.tagPaddingV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizing.radiusTag),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightMedium,
          color: textColor,
        ),
      ),
    );
  }
}
