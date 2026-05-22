// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:flutter/material.dart';

/// Layout del Home para orientación portrait (vertical)
///
/// ESTRUCTURA:
/// ```
/// SingleChildScrollView
/// └── Column
///     ├── HomeMenuCards  (grid de accesos rápidos)
///     ├── RecordatoriosSection
///     └── LeadsSection
/// ```
class HomePortrait extends StatelessWidget {
  final HomeLoaded state;

  const HomePortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── MENU CARDS ──────────────────────────────────────
          HomeMenuCards(
            inboxCount: state.chats.length,
            leadsCount: state.leads.length,
            recordatoriosCount: state.reminders.length,
          ),
          if (state.reminders.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            RemindersSection(reminders: state.reminders),
          ],
          if (state.leads.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            LeadsSection(leads: state.leads),
          ],

          if (state.leads.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ChatsSection(chats: state.chats),
          ],
        ],
      ),
    );
  }
}
