import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter/material.dart';

class RemindersSection extends StatelessWidget {
  final List<Reminder> reminders;
  const RemindersSection({super.key, required this.reminders});

  static const int _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
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
            // ── HEADER ────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Recordatorios',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (reminders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${reminders.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.xs),

            // ── LISTA O VACÍO ─────────────────────────────────
            if (reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: const AppEmptyView(
                  message: 'No tienes recordatorios pendientes',
                ),
              )
            else
              ...reminders.take(_maxVisible).toList().asMap().entries.map((e) {
                final isLast =
                    e.key == (reminders.length.clamp(0, _maxVisible) - 1);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RemindersTileHome(reminders: e.value),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 52,
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                  ],
                );
              }),

            // ── VER TODOS ─────────────────────────────────────
            if (reminders.length > _maxVisible) ...[
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: context.goToReminders,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    'Ver todos (${reminders.length})',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
