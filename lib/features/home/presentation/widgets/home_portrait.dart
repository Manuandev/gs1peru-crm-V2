// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:app_crm/features/home/presentation/widgets/dashboard/home_menu_cards.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/chats_section_home.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/leads_section_home.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/recordatorios_section_home.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/features/home/presentation/bloc/home_state.dart';

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
            recordatoriosCount: state.recordatorios.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── RECORDATORIOS ───────────────────────────────────
          RecordatoriosSection(recordatorios: state.recordatorios),
          const SizedBox(height: AppSpacing.lg),
          // ── NUEVOS LEADS ────────────────────────────────────
          LeadsSection(leads: state.leads),
          const SizedBox(height: AppSpacing.lg),
          // ── NUEVOS CHATS ────────────────────────────────────
          ChatsSection(chats: state.chats),
        ],
      ),
    );
  }
}
