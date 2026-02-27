// leads_section.dart — mismo patrón para recordatorios y prioridad

import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/tiles/recordatorio_tile.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:flutter/material.dart';

class RecordatoriosSection extends StatelessWidget {
  final List<RecordatorioItem> recordatorios;
  const RecordatoriosSection({super.key, required this.recordatorios});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER DE LA SECCIÓN ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nuevos recordatorios', style: AppTextStyles.titleMedium),
                if (recordatorios.isNotEmpty)
                  Text(
                    '${recordatorios.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const Divider(),

            // ── LISTA O VACÍO ─────────────────────────────────
            if (recordatorios.isEmpty)
              const _EmptySection(message: 'No tienes recordatorios pendientes')
            else
              // altura fija + scroll interno del card
              SizedBox(
                height: 100,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: recordatorios.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => RecordatorioTile(recordatorio: recordatorios[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para cuando no hay datos
class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
