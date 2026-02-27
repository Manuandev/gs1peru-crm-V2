// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:app_crm/features/home/presentation/widgets/dashboard/home_menu_cards.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/leads_section.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/recordatorios_section.dart';
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
            inboxCount: state.leads.length,
            recordatoriosCount: state.recordatorios.length,
          ),
          const SizedBox(height: AppSpacing.xl),
          // ── RECORDATORIOS ───────────────────────────────────
          RecordatoriosSection(recordatorios: state.recordatorios),
          const SizedBox(height: AppSpacing.xl),
          // ── NUEVOS LEADS ────────────────────────────────────
          LeadsSection(leads: state.leads),
        ],
      ),
    );
  }
}
