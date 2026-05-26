import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:flutter/material.dart';

class PrioridadSectionHome extends StatelessWidget {
  final List<Prioridad> prioridades;

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
          // ignore: deprecated_member_use
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                      // ignore: deprecated_member_use
                      color: colorScheme.outlineVariant.withOpacity(0.3),
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
