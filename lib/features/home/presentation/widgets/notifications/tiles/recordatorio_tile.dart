// lib/features/home/presentation/widgets/notifications/tiles/recordatorio_tile.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class RecordatorioTile extends StatelessWidget {
  final Recordatorio recordatorio;

  const RecordatorioTile({super.key, required this.recordatorio});

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
              // Nombre + fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    recordatorio.nombre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                  Text(
                    recordatorio.fechaHora.formatConDia(),
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
                recordatorio.nombreEmpresa,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(
                    alpha: AppColors.opacityTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Teléfono + asignado
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
                  Text(recordatorio.telefono, style: AppTextStyles.bodySmall),
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
                      recordatorio.asignadoA,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Acción + aviso (exclusivos de Recordatorio)
              Row(
                children: [
                  Icon(
                    AppIcons.accion,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    recordatorio.accion,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    AppIcons.time,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(recordatorio.aviso, style: AppTextStyles.bodySmall),
                ],
              ),

              // Comentario si existe
              if (recordatorio.comentario.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.chipGap),
                Text(
                  recordatorio.comentario,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityTextMuted,
                    ),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),

              // Tags
              Wrap(
                spacing: AppSpacing.chipGap,
                runSpacing: AppSpacing.xs,
                children: [
                  _Tag(
                    label: recordatorio.campania,
                    color: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                  ),
                  _Tag(
                    label: recordatorio.evento,
                    color: colorScheme.secondaryContainer,
                    textColor: colorScheme.onSecondaryContainer,
                  ),
                  _Tag(
                    label: recordatorio.canal,
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
