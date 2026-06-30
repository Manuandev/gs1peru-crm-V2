// lib/core/presentation/widgets/navigation/app_drawer_widget.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class AppDrawerWidget extends StatelessWidget {
  // Parámetros mantenidos para compatibilidad con BasePage.
  // La nueva implementación los ignora: la estructura del drawer
  // está hardcodeada y derivada del DrawerLoaded state.
  final List<DrawerItemModel>? items;
  final VoidCallback? onLogout;
  final VoidCallback? onSettings;
  final bool showSettings;
  final bool showLogout;

  const AppDrawerWidget({
    super.key,
    this.items,
    this.onLogout,
    this.onSettings,
    this.showSettings = true,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    return const _DrawerContent();
  }
}

// ── Contenido del drawer ───────────────────────────────────────────────────────

class _DrawerContent extends StatelessWidget {
  const _DrawerContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) {
        if (state is! DrawerLoaded) return const SizedBox.shrink();

        final String? rutaActual = ModalRoute.of(context)?.settings.name;

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                _DrawerHeader(state: state),
                const SizedBox(height: AppSpacing.xs),

                // ── Ítems principales (scrollables) ───────────────
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _DrawerItem(
                        item: const DrawerItemModel(
                          id: AppRoutes.home,
                          icon: AppIcons.home,
                          label: 'Inicio',
                          route: AppRoutes.home,
                        ),
                        isActive: rutaActual == AppRoutes.home,
                      ),
                      _DrawerItem(
                        item: DrawerItemModel(
                          id: AppRoutes.chats,
                          icon: AppIcons.message,
                          label: 'Conversaciones',
                          route: AppRoutes.chats,
                          badge: state.conversaciones > 0
                              ? state.conversaciones
                              : null,
                        ),
                        isActive: rutaActual == AppRoutes.chats,
                      ),
                      _DrawerItem(
                        item: const DrawerItemModel(
                          id: AppRoutes.seguimiento,
                          icon: AppIcons.users,
                          label: 'Seguimiento',
                          route: AppRoutes.seguimiento,
                        ),
                        isActive: rutaActual == AppRoutes.seguimiento,
                      ),
                      // _DrawerItem(
                      //   item: const DrawerItemModel(
                      //     id: AppRoutes.contactos,
                      //     icon: AppIcons.documento,
                      //     label: 'Contactos',
                      //     route: AppRoutes.contactos,
                      //   ),
                      //   isActive: rutaActual == AppRoutes.contactos,
                      // ),
                      _DrawerItem(
                        item: const DrawerItemModel(
                          id: AppRoutes.solicitudes,
                          icon: AppIcons.email,
                          label: 'Solicitudes',
                          route: AppRoutes.solicitudes,
                        ),
                        isActive: rutaActual == AppRoutes.solicitudes,
                      ),
                      _DrawerItem(
                        item: const DrawerItemModel(
                          id: AppRoutes.cobranza,
                          icon: AppIcons.moneda,
                          label: 'Cobranza',
                          route: AppRoutes.cobranza,
                        ),
                        isActive: rutaActual == AppRoutes.cobranza,
                      ),
                    ],
                  ),
                ),

                // ── Sección inferior pineada al fondo ─────────────
                // if (state.isModerador) ...[
                //   const Padding(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: AppSpacing.lg,
                //       vertical: AppSpacing.sm,
                //     ),
                //     child: Divider(color: AppColors.border),
                //   ),
                //   Padding(
                //     padding: const EdgeInsets.only(
                //       left: AppSpacing.lg,
                //       bottom: AppSpacing.xs,
                //     ),
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Text(
                //         'Accesos rápidos',
                //         style: AppTextStyles.labelSmall.copyWith(
                //           color: AppColors.textSecondary,
                //         ),
                //       ),
                //     ),
                //   ),
                //   BlocBuilder<FiltroCubit, FiltroState>(
                //     builder: (context, filtroState) {
                //       final esMiEquipo =
                //           filtroState.vista == FiltroVista.miEquipo;
                //       return Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           _AccesoRapidoItem(
                //             icon: AppIcons.user,
                //             label: 'Mis casos',
                //             isSeleccionado: !esMiEquipo,
                //             onTap: () {
                //               context.read<FiltroCubit>().cambiarVista(
                //                 FiltroVista.misCasos,
                //               );
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //           _AccesoRapidoItem(
                //             icon: AppIcons.users,
                //             label: 'Equipo',
                //             isSeleccionado: esMiEquipo,
                //             onTap: () {
                //               context.read<FiltroCubit>().cambiarVista(
                //                 FiltroVista.miEquipo,
                //               );
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                // ],
                Divider(color: AppColors.border),
                // ── Cerrar sesión — siempre al fondo ──────────────
                _DrawerItem(
                  item: DrawerItemModel(
                    id: '__logout__',
                    icon: AppIcons.logout,
                    label: 'Cerrar sesión',
                    onTap: () => context.logoutWithConfirmation(context),
                  ),
                  isActive: false,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header rediseñado: logo GS1 + "CRM Perú" + rol ───────────────────────────

class _DrawerHeader extends StatelessWidget {
  final DrawerLoaded state;
  const _DrawerHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final String rol = state.isModerador ? 'Supervisor' : 'Asesor';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          SvgPicture.asset(
            AppImages.logoGs1PeruBlanco,
            height: AppSizing.avatarSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'CRM Perú',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    StreamBuilder<WebSocketConnectionState>(
                      stream: SignalRService.instance.connectionStateStream,
                      initialData: SignalRService.instance.currentState,
                      builder: (context, snapshot) {
                        final state = snapshot.data!;
                        return _SocketChip(state: state);
                      },
                    ),
                  ],
                ),
                Text(
                  rol,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnDark.withValues(
                      alpha: AppColors.opacityOnPrimarySubtle,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'v${AppConstants.version}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnDark.withValues(
                      alpha: AppColors.opacityOnPrimarySubtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip de estado de conexión SignalR ────────────────────────────────────────

class _SocketChip extends StatelessWidget {
  final WebSocketConnectionState state;
  const _SocketChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      WebSocketConnectionState.connected => ('● En línea', AppColors.success),
      WebSocketConnectionState.connecting => (
        '● Conectando',
        AppColors.warning,
      ),
      WebSocketConnectionState.reconnecting => (
        '● Reconectando',
        AppColors.warning,
      ),
      WebSocketConnectionState.disconnected => (
        '● Sin conexión',
        AppColors.error,
      ),
      WebSocketConnectionState.noInternet => (
        '● Sin internet',
        AppColors.error,
      ),
      WebSocketConnectionState.manuallyClosed => ('', AppColors.transparent),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Text(label, style: AppTextStyles.labelSmall.copyWith(color: color));
  }
}

// ── Ítem del drawer ───────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final DrawerItemModel item;
  final bool isActive;

  const _DrawerItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final iconColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final textColor = isActive ? colorScheme.primary : colorScheme.onSurface;

    final bgColor = isActive
        ? colorScheme.primary.withValues(alpha: AppColors.opacityActiveItem)
        : AppColors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              onTap: () => _handleTap(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + AppSpacing.xxs,
                ),
                child: Row(
                  children: [
                    item.icon is IconData
                        ? Icon(
                            item.icon as IconData,
                            color: iconColor,
                            size: AppSizing.iconNav,
                          )
                        : SizedBox(
                            width: AppSizing.iconNav,
                            height: AppSizing.iconNav,
                            child: Center(
                              child: FaIcon(
                                item.icon,
                                color: iconColor,
                                size: AppSizing.iconActionSm,
                              ),
                            ),
                          ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textColor,
                          fontWeight: isActive
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                      ),
                    ),
                    if (item.badge != null && item.badge! > 0)
                      _Badge(count: item.badge!),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (item.showDividerAfter)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(height: AppSpacing.sm),
          ),
      ],
    );
  }

  void _handleTap(BuildContext context) {
    // El logout maneja su propio cierre — no hacer pop aquí
    if (item.id == '__logout__') {
      item.onTap?.call();
      return;
    }

    Navigator.of(context).pop();
    if (item.onTap != null) {
      item.onTap!();
      return;
    }
    if (isActive) return;
    if (item.route != null) context.clearAndPush(item.route!);
  }
}

// ── Ítem de acción para "Accesos rápidos" ────────────────────────────────────
// Muestra el ítem actualmente seleccionado como deshabilitado (opacidad + sin ripple).
// El ítem no seleccionado es interactivo y llama a FiltroCubit al tapear.

// class _AccesoRapidoItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isSeleccionado;
//   final VoidCallback onTap;

//   const _AccesoRapidoItem({
//     required this.icon,
//     required this.label,
//     required this.isSeleccionado,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     // Ítem seleccionado: mismo estilo que nav-ítem activo, sin ripple ni tap
//     if (isSeleccionado) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppSpacing.sm,
//           vertical: AppSpacing.xxs,
//         ),
//         child: Material(
//           color: colorScheme.primary.withValues(
//             alpha: AppColors.opacityActiveItem,
//           ),
//           borderRadius: BorderRadius.circular(AppSizing.radiusMd),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppSpacing.md,
//               vertical: AppSpacing.sm + AppSpacing.xxs,
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, color: colorScheme.primary, size: AppSizing.iconNav),
//                 const SizedBox(width: AppSpacing.md),
//                 Expanded(
//                   child: Text(
//                     label,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: colorScheme.primary,
//                       fontWeight: AppTextStyles.weightSemiBold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // Ítem no seleccionado: interactivo con ripple
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.sm,
//         vertical: AppSpacing.xxs,
//       ),
//       child: Material(
//         color: AppColors.transparent,
//         borderRadius: BorderRadius.circular(AppSizing.radiusMd),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(AppSizing.radiusMd),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppSpacing.md,
//               vertical: AppSpacing.sm + AppSpacing.xxs,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: colorScheme.onSurfaceVariant,
//                   size: AppSizing.iconNav,
//                 ),
//                 const SizedBox(width: AppSpacing.md),
//                 Expanded(
//                   child: Text(
//                     label,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: colorScheme.onSurface,
//                       fontWeight: AppTextStyles.weightRegular,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ── Badge numérico ────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chipGap,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onPrimary,
          fontSize: AppTextStyles.sizeXs,
        ),
      ),
    );
  }
}
