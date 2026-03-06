// leads_section.dart — mismo patrón para recordatorios y prioridad


import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter/material.dart';

class RemindersSection extends StatelessWidget {
  final List<Reminder> reminders;

  const RemindersSection({super.key, required this.reminders});

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
                if (reminders.isNotEmpty)
                  Text(
                    '${reminders.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const Divider(),

            // ── LISTA O VACÍO ─────────────────────────────────
            if (reminders.isEmpty)
              const AppEmptyView(message: 'No tienes recordatorios pendientes')
            else
              // altura fija + scroll interno del card
              SizedBox(
                height: 100,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: reminders.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      RemindersTileHome(reminders: reminders[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
