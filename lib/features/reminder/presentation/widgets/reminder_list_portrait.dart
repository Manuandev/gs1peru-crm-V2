// lib\features\reminder\presentation\widgets\reminder_list_portrait.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter/material.dart';

class ReminderListPortrait extends StatelessWidget {
  final ReminderListLoaded state;

  const ReminderListPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aquí está el resumen de hoy', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),

          ...state.reminders.map(
            (lead) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(lead.nomApe),
                subtitle: Text(
                  '${lead.accion} - ${lead.aviso} - ${lead.hora}'
                  '${lead.comentario.isNotEmpty ? '\n${lead.comentario}' : ''}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
