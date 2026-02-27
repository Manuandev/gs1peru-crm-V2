

import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_bloc.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_event.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_state.dart';
import 'package:app_crm/features/recordatorios/presentation/widgets/recordatorios_landscape.dart';
import 'package:app_crm/features/recordatorios/presentation/widgets/recordatorios_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/core/presentation/pages/base_page.dart';
import 'package:app_crm/core/presentation/widgets/navigation/drawer_item_model.dart';

class RecordatoriosView extends StatelessWidget {
  const RecordatoriosView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      title: 'Recordatorios',
      drawerSide: DrawerSide.left,
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.notification, color: AppColors.textOnDark),
          onPressed: () {},
        ),
      ],
      appBarPopupItems: const [
        AppBarPopupItem(
          value: 'refresh',
          icon: AppIcons.refresh,
          label: 'Actualizar',
        ),
        AppBarPopupItem(
          value: 'help',
          icon: AppIcons.help,
          label: 'Ayuda',
          showDividerAfter: true,
        ),
      ],
      onPopupSelected: (value) {
        if (value == 'refresh') {
          context.read<RecordatoriosBloc>().add(RecordatoriosRefreshRequested());
        }
      },
      body: BlocBuilder<RecordatoriosBloc, RecordatoriosState>(
        builder: (context, state) {
          if (state is RecordatoriosLoading || state is RecordatoriosInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecordatoriosError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.error,
                    size: AppSizing.iconXl,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Error al cargar', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RecordatoriosBloc>().add(RecordatoriosRefreshRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is RecordatoriosLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return RecordatoriosLandscape(state: state);
                }
                return RecordatoriosPortrait(state: state);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================
// Cuerpo principal del Home
// ============================================================

/// _HomeBody — Contenido scrollable de la pantalla de inicio
///
/// Recibe el [HomeLoaded] para mostrar datos del usuario.
/// Espacio reservado para los widgets reales del home (cards, estadísticas, etc.)

// ============================================================
// Footer fijo del Home
// ============================================================
// _HomeFooter — Barra inferior fija con información de versión
//
// Se muestra siempre en la parte inferior de la pantalla de inicio.
// Usa colores del tema de Material 3 para adaptarse a dark/light mode.
// Por si es necesario mostrar otro footer en una pantalla
// class _HomeFooter extends StatelessWidget {
//   const _HomeFooter();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.lg,
//         vertical: AppSpacing.sm,
//       ),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         border: Border(
//           top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
//         ),
//       ),
//       child: Text(
//         'v1.0.0 — Mi App',
//         style: AppTextStyles.labelSmall,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
