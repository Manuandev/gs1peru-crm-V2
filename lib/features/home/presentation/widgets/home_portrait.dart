// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

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
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTotalesHome(state: state),
          const SizedBox(height: AppSpacing.md),
          HomeMenuCards(state: state),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Prioridad ahora',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Responde rápido a tus conversaciones.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrioridadSectionHome(prioridades: state.prioridades),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prospectos nuevos',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              CustomTextButton(text: 'Ver todos', onPressed: () {}),
            ],
          ),
          ProspectosSectionHome(prospectos: state.prospectos),
        ],
      ),
    );
  }
}
