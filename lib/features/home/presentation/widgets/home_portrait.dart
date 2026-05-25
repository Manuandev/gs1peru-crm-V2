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
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

    final titleStyle = themeText.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: themeText.titleMedium!.color,
    );

    final bodyStyle = themeText.bodySmall?.copyWith(
      color: themeText.bodySmall!.color,
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('totalConversaciones: ${state.totConversaciones}'),
          Text('totCobranza: ${state.totCobranza}'),
          Text('totProspectos: ${state.totProspectos}'),
          Text('totPropuesta: ${state.totPropuesta}'),
          // ── MENU CARDS ──────────────────────────────────────
          HomeMenuCards(state: state),
          const SizedBox(height: AppSpacing.md),
          Text("Prioridad ahora", style: titleStyle),
          const SizedBox(height: AppSpacing.xxs),
          Text("Responde rápido a tus conversaciones.", style: bodyStyle),
          PrioridadSectionHome(prioridades: state.prioridades),
        ],
      ),
    );
  }
}
