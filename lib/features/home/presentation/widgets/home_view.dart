// lib/features/home/presentation/widgets/home_view.dart

import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/home/presentation/widgets/home_Portrait.dart';
import 'package:app_crm/features/home/presentation/widgets/home_landscape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/core/presentation/pages/base_page.dart';
import 'package:app_crm/core/presentation/widgets/navigation/drawer_item_model.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// HomeView — Vista principal del Home
///
/// PROPÓSITO:
/// - Renderizar el estado del [HomeBloc] en pantalla
/// - Mostrar loading, error o el contenido principal según el estado
/// - No hace navegación directamente (eso lo hace [HomePage] vía BlocListener)
///
/// ESTADOS QUE MANEJA:
/// - [HomeInitial] / [HomeLoading]  → Spinner centrado
/// - [HomeError]                    → Mensaje de error + botón reintentar
/// - [HomeLoaded]                   → Layout completo con [BasePage]
///
/// REGLA DE ESTILO:
/// NO hardcodea íconos, colores ni tamaños.
/// Usa únicamente constantes del design system:
///   - Íconos  → [AppIcons]
///   - Espacios → [AppSpacing], [AppSizing]
///   - Texto   → [AppTextStyles]
///
/// ESTRUCTURA:
/// - [HomeView]     → BlocBuilder principal
/// - [_HomeBody]    → Contenido del scroll principal
/// - [_HomeFooter]  → Barra inferior fija con versión
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      titleWidget: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            final nombre = state.usuario.userApe.split(' ');

            return Text(
              'Hola, ${nombre[0]} 👋',
              style: AppTextStyles.titleMedium.copyWith(),
            );
          }
          return const Text('Inicio');
        },
      ),
      drawerSide: DrawerSide.left,
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
          onPressed: () {
            context.read<HomeBloc>().add(HomeRefreshRequested());
          },
        ),
      ],
      // appBarPopupItems: const [
      //   AppBarPopupItem(
      //     value: 'refresh',
      //     icon: AppIcons.refresh,
      //     label: 'Actualizar',
      //   ),
      //   AppBarPopupItem(
      //     value: 'help',
      //     icon: AppIcons.help,
      //     label: 'Ayuda',
      //     showDividerAfter: true,
      //   ),
      // ],
      // onPopupSelected: (value) {
      //   if (value == 'refresh') {
      //     context.read<HomeBloc>().add(HomeRefreshRequested());
      //   }
      // },
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
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
                        context.read<HomeBloc>().add(HomeRefreshRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return HomeLandscape(state: state);
                }
                return HomePortrait(state: state);
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
