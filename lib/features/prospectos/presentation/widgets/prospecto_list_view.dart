// // lib\features\reminder\presentation\widgets\reminder_list_view.dart

// import 'package:flutter/material.dart';
// import 'package:app_crm/index_dependencies.dart';

// import 'package:app_crm/config/index_config.dart';
// import 'package:app_crm/core/index_core.dart';
// import 'package:app_crm/features/prospectos/index_prospectos.dart';

// class ProspectoListView extends StatelessWidget {
//   const ProspectoListView({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return BasePage(
//       onLogout: () => context.logoutWithConfirmation(context),
//       title: 'Prospectos',
//       drawerSide: DrawerSide.left,
//       appBarTrailingButtons: [
//         IconButton(
//           icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
//           onPressed: () {
//             context.read<ProspectoListBloc>().add(ProspectoListRefresh());
//           },
//         ),
//       ],
//       body: BlocBuilder<ProspectoListBloc, ProspectoListState>(
//         builder: (context, state) {
//           if (state is ProspectoListLoading || state is ProspectoListInitial) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is ProspectoListError) {
//             return AppErrorView(
//               message: state.message,
//               onRetry: () =>
//                   context.read<ProspectoListBloc>().add(ProspectoListRefresh()),
//             );
//           }

//           if (state is ProspectoListLoaded) {
//             if (state.prospectos.isEmpty) return const AppEmptyView(message: 'No hay prospectos disponibles.',);

//             return OrientationBuilder(
//               builder: (context, orientation) {
//                 if (orientation == Orientation.landscape) {
//                   return ProspectoListLandscape(state: state);
//                 }
//                 return ProspectoListPortrait(state: state);
//               },
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// // ============================================================
// // Cuerpo principal del Home
// // ============================================================

// /// _HomeBody — Contenido scrollable de la pantalla de inicio
// ///
// /// Recibe el [HomeLoaded] para mostrar datos del usuario.
// /// Espacio reservado para los widgets reales del home (cards, estadísticas, etc.)

// // ============================================================
// // Footer fijo del Home
// // ============================================================
// // _HomeFooter — Barra inferior fija con información de versión
// //
// // Se muestra siempre en la parte inferior de la pantalla de inicio.
// // Usa colores del tema de Material 3 para adaptarse a dark/light mode.
// // Por si es necesario mostrar otro footer en una pantalla
// // class _HomeFooter extends StatelessWidget {
// //   const _HomeFooter();
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: AppSpacing.lg,
// //         vertical: AppSpacing.sm,
// //       ),
// //       decoration: BoxDecoration(
// //         color: Theme.of(context).colorScheme.surfaceContainerHighest,
// //         border: Border(
// //           top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
// //         ),
// //       ),
// //       child: Text(
// //         'v1.0.0 — Mi App',
// //         style: AppTextStyles.labelSmall,
// //         textAlign: TextAlign.center,
// //       ),
// //     );
// //   }
// // }
