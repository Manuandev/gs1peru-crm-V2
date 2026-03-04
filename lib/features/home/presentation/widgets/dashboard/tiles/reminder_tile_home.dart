// lead_tile.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter/material.dart';

class RemindersTileHome extends StatelessWidget {
  final Reminder reminders;
  const RemindersTileHome({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    // Color del ícono según acción
    final iconColor =
        reminders.accion.toLowerCase().contains('enviar whatsapp')
        ? Colors.green
        : Colors.blue;

    final icon = reminders.accion.toLowerCase().contains('enviar whatsapp')
        ? AppIcons.chat
        : AppIcons.phone;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── ÍCONO ────────────────────────────────────────
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── HORA + ACCIÓN + NOMBRE ────────────────────────
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '${reminders.hora}  ',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: reminders.accion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' — ${reminders.modalidad}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
