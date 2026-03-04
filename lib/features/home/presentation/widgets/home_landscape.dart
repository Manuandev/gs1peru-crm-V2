// lib/features/home/presentation/widgets/home_landscape.dart


import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:flutter/material.dart';

/// Layout del Home para orientación landscape (horizontal)
///
/// ESTRUCTURA:
/// ```
/// Row
/// ├── Expanded(flex:4) → Menu cards (columna izquierda)   [scrollable]
/// └── Expanded(flex:6) → Leads + Recordatorios            [scrollable]
/// ```
class HomeLandscape extends StatelessWidget {
  final HomeLoaded state;

  const HomeLandscape({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── COLUMNA IZQUIERDA: MENU ──────────────────────────
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: HomeMenuCards(
              inboxCount: state.chats.length,
              leadsCount: state.leads.length,
              recordatoriosCount: state.reminders.length,
            ),
          ),
        ),
        // Separador vertical
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // ── COLUMNA DERECHA: DATOS ───────────────────────────
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RemindersSection(reminders: state.reminders),
                const SizedBox(height: AppSpacing.lg),
                LeadsSection(leads: state.leads),
                const SizedBox(height: AppSpacing.lg),
                ChatsSection(chats: state.chats),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
