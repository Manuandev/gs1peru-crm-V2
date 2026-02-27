// lib/core/presentation/widgets/navigation/app_drawer_widget.dart
//
// EL DRAWER ES AUTÓNOMO.
// Nadie le pasa nombre, email, avatar ni badges desde afuera.
// Él crea su propio DrawerBloc y carga todo solo.
// Solo se le pasa lo que es VARIABLE por pantalla:
//   - ítems del menú (default: AppMenuItems.mainItems)
//   - callbacks de logout/settings si se quieren pisar

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/presentation/bloc/drawer/drawer_bloc.dart';
import 'package:app_crm/core/presentation/bloc/drawer/drawer_state.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:app_crm/core/constants/app_menu_items.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'drawer_item_model.dart';

class AppDrawerWidget extends StatelessWidget {
  /// Ítems del menú. Por default usa AppMenuItems.mainItems.
  /// Solo pásalo si esta pantalla necesita un menú diferente.
  final List<DrawerItemModel>? items;

  /// Callback custom para logout. Por default navega a Login.
  final VoidCallback? onLogout;

  /// Callback custom para configuración. Por default navega a changePassword.
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
    // ✅ Dejar solo esto
    return _DrawerContent(
      items: items,
      onLogout: onLogout,
      onSettings: onSettings,
      showSettings: showSettings,
      showLogout: showLogout,
    );
  }
}

// ============================================================
// Contenido interno del drawer — lee del DrawerBloc
// ============================================================

class _DrawerContent extends StatelessWidget {
  final List<DrawerItemModel>? items;
  final VoidCallback? onLogout;
  final VoidCallback? onSettings;
  final bool showSettings;
  final bool showLogout;

  const _DrawerContent({
    this.items,
    this.onLogout,
    this.onSettings,
    this.showSettings = true,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) {
        if (state is! DrawerLoaded) return const SizedBox.shrink();

        final String? currentRoute = ModalRoute.of(context)?.settings.name;

        // Ítems con badges si los hay, o los simples si no
        final List<DrawerItemModel> menuItems = _resolveItems(state);

        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── HEADER ──────────────────────────────────────
                _DrawerHeader(state: state),
                const SizedBox(height: AppSpacing.xs),
                // ── ÍTEMS ────────────────────────────────────────
                ...menuItems.map(
                  (item) => _DrawerItem(
                    item: item,
                    isActive: item.id == currentRoute,
                  ),
                ),
                // ── DEFAULTS (configuración + logout) ────────────
                const Divider(height: 1),
                if (showSettings)
                  _DrawerItem(
                    item: DrawerItemModel(
                      id: AppRoutes.changePassword,
                      icon: Icons.settings_outlined,
                      label: 'Configuración',
                      onTap: onSettings ?? () => context.goToChangePassword(),
                    ),
                    isActive: currentRoute == AppRoutes.changePassword,
                  ),

                if (showLogout)
                  _DrawerItem(
                    item: DrawerItemModel(
                      id: '__logout__',
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      // onTap:
                      //     onLogout ??
                      //     () => context.logoutWithConfirmation(context),
                      onTap:
                          onLogout ??
                          () async {
                            // NO cierres el drawer aquí — el dialog necesita el contexto
                            final confirmed = await context.showConfirmDialog(
                              title: 'Cerrar Sesión',
                              message: '¿Estás seguro que deseas salir?',
                              confirmText: 'Salir',
                              cancelText: 'Cancelar',
                            );
                            if (confirmed) {
                              // Usa navigatorKey directamente — no depende del context del drawer
                              NavigationService.navigatorKey.currentContext!
                                  .read<AuthBloc>()
                                  .add(const AuthLogoutRequested());
                            }
                          },
                    ),
                    isActive: false,
                    isDestructive: true,
                  ),

                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DrawerItemModel> _resolveItems(DrawerState state) {
    // Si el caller pasó ítems custom, usarlos
    if (items != null) return items!;

    // Si el BLoC cargó datos y hay badges, ítems con badges
    if (state is DrawerLoaded && state.hasBadges) {
      return AppMenuItems.withBadges(
        chatsBadge: state.unreadChats,
        recordatoriosBadge: state.pendingRecordatorios,
        leadsBadge: state.newLeads,
      );
    }

    // Default: ítems sin badges
    return AppMenuItems.mainItems;
  }
}

// ============================================================
// Header del drawer — muestra estado de carga o datos reales
// ============================================================

class _DrawerHeader extends StatelessWidget {
  final DrawerState state;
  const _DrawerHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final isLandscape = size.width > size.height;
    final isSmallHeight = size.height < 500;
    final compact = isLandscape && isSmallHeight;

    final avatarRadius = compact ? 20.0 : 30.0;
    final verticalPadding = compact ? AppSpacing.md : AppSpacing.xl;

    Widget avatar({String? imageUrl}) {
      return CircleAvatar(
        radius: avatarRadius,
        backgroundColor: colorScheme.onPrimary,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Icon(
                AppIcons.user,
                size: compact ? AppSizing.iconMd : AppSizing.iconLg,
                color: colorScheme.primary,
              )
            : null,
      );
    }

    // Mientras carga → skeleton simple
    if (state is! DrawerLoaded) return const SizedBox.shrink();

    final loaded = state as DrawerLoaded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        verticalPadding,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      color: colorScheme.primary,
      child: compact
          ? Row(
              children: [
                avatar(imageUrl: loaded.userAvatarUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    loaded.userApe,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar(imageUrl: loaded.userAvatarUrl),
                const SizedBox(height: AppSpacing.md),
                Text(
                  loaded.userApe,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                if (loaded.userSubtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    loaded.userSubtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      // ignore: deprecated_member_use
                      color: colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ============================================================
// Cada fila del drawer
// ============================================================

class _DrawerItem extends StatelessWidget {
  final DrawerItemModel item;
  final bool isActive;
  final bool isDestructive;

  const _DrawerItem({
    required this.item,
    required this.isActive,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color iconColor = isDestructive
        ? colorScheme.error
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final Color textColor = isDestructive
        ? colorScheme.error
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface;

    final Color bgColor = isActive
        // ignore: deprecated_member_use
        ? colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
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
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: iconColor, size: 22),
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
    // Cerrar drawer siempre primero
    Navigator.of(context).pop();

    // Si tiene acción custom, ejecutarla
    if (item.onTap != null) {
      item.onTap!();
      return;
    }

    // Si ya estamos aquí, no navegar
    if (isActive) return;

    // ✅ Usa clearStackAndNavigateTo — limpia el stack completo
    if (item.route != null) {
      context.clearStackAndNavigateTo(item.route!);
    }
  }
}

// ============================================================
// Badge numérico
// ============================================================

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
