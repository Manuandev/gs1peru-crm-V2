// lib\features\reminder\presentation\widgets\reminder_list_view.dart


import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeadListView extends StatelessWidget {
  const LeadListView({super.key});

  @override
  Widget build(BuildContext context) {

    return BasePage(
      onLogout: () => context.logoutWithConfirmation(context),
      title: 'Leads',
      drawerSide: DrawerSide.left,
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
          onPressed: () {
            context.read<LeadListBloc>().add(LeadListRefresh());
          },
        ),
      ],
      body: BlocBuilder<LeadListBloc, LeadListState>(
        builder: (context, state) {
          if (state is LeadListLoading || state is LeadListInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeadListError) {
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<LeadListBloc>().add(LeadListRefresh()),
            );
          }

          if (state is LeadListLoaded) {
            if (state.leads.isEmpty) return const AppEmptyView(message: 'No hay leads disponibles.',);

            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return LeadListLandscape(state: state);
                }
                return LeadListPortrait(state: state);
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
