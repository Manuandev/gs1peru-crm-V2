// lib/features/home/presentation/widgets/home_landscape.dart

import 'package:app_crm/features/home/presentation/widgets/dashboard/home_menu_cards.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/leads_section.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/sections/recordatorios_section.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/features/home/presentation/bloc/home_state.dart';

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
              inboxCount: state.leads.length,
              recordatoriosCount: state.recordatorios.length,
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
                RecordatoriosSection(recordatorios: state.recordatorios),
                const SizedBox(height: AppSpacing.xl),
                LeadsSection(leads: state.leads),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
