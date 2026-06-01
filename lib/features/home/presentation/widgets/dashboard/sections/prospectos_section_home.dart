// lib/features/home/presentation/widgets/dashboard/sections/prospectos_section_home.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class ProspectosSectionHome extends StatelessWidget {
  final List<ProspectoHome> prospectos;

  const ProspectosSectionHome({super.key, required this.prospectos});

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
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...prospectos.take(_maxVisible).toList().asMap().entries.map((e) {
              final isLast =
                  e.key == (prospectos.length.clamp(0, _maxVisible) - 1);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProspectoTileHome(prospecto: e.value),
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
