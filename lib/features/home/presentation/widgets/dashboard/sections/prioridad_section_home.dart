// lib/features/home/presentation/widgets/dashboard/sections/prioridad_section_home.dart
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadSectionHome extends StatelessWidget {
  final List<PrioridadHome> prioridades;

  const PrioridadSectionHome({super.key, required this.prioridades});

  static const int _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(
            alpha: AppColors.opacityDisabledBorder,
          ),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...prioridades.take(_maxVisible).toList().asMap().entries.map((e) {
              final isLast =
                  e.key == (prioridades.length.clamp(0, _maxVisible) - 1);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrioridadTileHome(prioridad: e.value),
                  if (!isLast)
                    Divider(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: AppColors.opacityDivider,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
