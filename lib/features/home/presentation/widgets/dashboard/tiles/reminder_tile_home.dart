import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter/material.dart';

class RemindersTileHome extends StatelessWidget {
  final Reminder reminders;
  const RemindersTileHome({super.key, required this.reminders});

  bool get _esWhatsapp =>
      reminders.accion.toLowerCase().contains('enviar whatsapp');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final iconData = _esWhatsapp ? AppIcons.chat : AppIcons.phone;
    final bgColor = _esWhatsapp
        ? Colors.green.shade50
        : colorScheme.primaryContainer;
    final iconColor = _esWhatsapp
        ? Colors.green.shade700
        : colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── ÍCONO ─────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── ACCIÓN + MODALIDAD ────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reminders.accion,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  reminders.modalidad,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── HORA ──────────────────────────────────────────
          Text(
            reminders.hora,
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}