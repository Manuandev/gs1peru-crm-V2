// lib/core/presentation/widgets/navigation/app_drawer_widget.dart
//
// ✅ FIX: Ya NO importa nada de features/auth.
//    El logout se resuelve con el callback onLogout que
//    cada page pasa desde su propio contexto.
//    core → auth  ❌  (eliminado)
//    page → auth  ✅  (la page conoce AuthBloc, no el drawer)

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawerWidget extends StatelessWidget {
  final List<DrawerItemModel>? items;

  /// ✅ Callback de logout — lo pasa cada page que usa BasePage.
  /// La lógica de AuthBloc vive en la page, no aquí.
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
    return _DrawerContent(
      items: items,
      onLogout: onLogout,
      onSettings: onSettings,
      showSettings: showSettings,
      showLogout: showLogout,
    );
  }
}

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
        final List<DrawerItemModel> menuItems = _resolveItems(state);

        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerHeader(state: state),
                const SizedBox(height: AppSpacing.xs),
                ...menuItems.map(
                  (item) => _DrawerItem(
                    item: item,
                    isActive: item.id == currentRoute,
                  ),
                ),
                const Divider(height: 1),
                if (showSettings)
                  _DrawerItem(
                    item: DrawerItemModel(
                      id: AppRoutes.settings,
                      icon: Icons.settings_outlined,
                      label: 'Configuración',
                      onTap: onSettings ?? () => context.goToSettings(),
                    ),
                    isActive: currentRoute == AppRoutes.settings,
                  ),
                if (showLogout)
                  _DrawerItem(
                    item: DrawerItemModel(
                      id: '__logout__',
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      // ✅ Solo ejecuta el callback que viene de la page.
                      // Quien sabe de AuthBloc es la page, no el drawer.
                      onTap: onLogout ?? () {},
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
    if (items != null) return items!;
    if (state is DrawerLoaded && state.hasBadges) {
      return AppMenuItems.withBadges(
        chatsBadge: state.unreadChats,
        remindersBadge: state.pendingReminders,
        leadsBadge: state.newLeads,
      );
    }
    return AppMenuItems.mainItems;
  }
}

// ============================================================
// Header del drawer
// ============================================================

class _DrawerHeader extends StatelessWidget {
  final DrawerState state;
  const _DrawerHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final compact = size.width > size.height && size.height < 500;
    final avatarRadius = compact ? 20.0 : 30.0;
    final verticalPadding = compact ? AppSpacing.md : AppSpacing.xl;

    if (state is! DrawerLoaded) return const SizedBox.shrink();
    final loaded = state as DrawerLoaded;

    Widget avatar() => CircleAvatar(
      radius: avatarRadius,
      backgroundColor: colorScheme.onPrimary,
      backgroundImage: loaded.userAvatarUrl != null
          ? NetworkImage(loaded.userAvatarUrl!)
          : null,
      child: loaded.userAvatarUrl == null
          ? Icon(
              AppIcons.user,
              size: compact ? AppSizing.iconMd : AppSizing.iconLg,
              color: colorScheme.primary,
            )
          : null,
    );

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
                avatar(),
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
                avatar(),
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
// Ítem del drawer
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

    final iconColor = isDestructive
        ? colorScheme.error
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final textColor = isDestructive
        ? colorScheme.error
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface;

    // ignore: deprecated_member_use
    final bgColor = isActive
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
    if (item.route != null) context.clearStackAndNavigateTo(item.route!);
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
    final colorScheme = Theme.of(context).colorScheme;
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
