// lib/core/presentation/widgets/navigation/custom_app_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// CustomAppBar — AppBar completamente personalizable
///
/// CARACTERÍSTICAS:
/// - Drawer a la izquierda O derecha (nunca los dos)
/// - Botones a la izquierda y/o derecha (respetan posición del drawer)
/// - Menú popup moderno: bordes redondeados, sombra suave, íconos en primary
/// - Animación de rotación 90° en el ícono del popup al abrir/cerrar
/// - Íconos con ripple visible (24% onPrimary al presionar)
/// - Badge de notificaciones con animación de pulso suave
/// - Título como String o Widget custom
///
/// REGLAS:
/// - drawerSide = left  → no puedes poner leadingButtons (el ícono del drawer ocupa ese espacio)
/// - drawerSide = right → los leadingButtons sí funcionan
/// - drawerSide = none  → leadingButtons y trailingButtons libres
///
/// USO:
/// CustomAppBar(
///   title: 'Leads',
///   drawerSide: DrawerSide.left,
///   notificationCount: 3,
///   onNotification: () { ... },
///   popupItems: [
///     AppBarPopupItem(value: 'refresh', icon: Icons.refresh, label: 'Actualizar'),
///   ],
///   onPopupSelected: (value) { ... },
/// )

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final DrawerSide drawerSide;
  final List<Widget>? leadingButtons;
  final List<Widget>? trailingButtons;
  final List<AppBarPopupItem>? popupItems;
  final void Function(String value)? onPopupSelected;
  final bool showElevation;
  final Color? backgroundColor;
  final void Function(String query)? onSearch;

  /// Número de notificaciones pendientes.
  /// null = sin ícono | 0 = ícono sin badge | >0 = badge con número y pulso
  final int? notificationCount;

  /// Acción al tocar el ícono de notificaciones.
  /// Requerido cuando [notificationCount] no es null.
  final VoidCallback? onNotification;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.drawerSide = DrawerSide.left,
    this.leadingButtons,
    this.trailingButtons,
    this.popupItems,
    this.onPopupSelected,
    this.showElevation = false,
    this.backgroundColor,
    this.onSearch,
    this.notificationCount,
    this.onNotification,
  }) : assert(
         title != null || titleWidget != null,
         'CustomAppBar necesita title o titleWidget',
       );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> with TickerProviderStateMixin {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  // Pulso del badge — anillo que se expande y desvanece cíclicamente
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScaleAnim;
  late final Animation<double> _pulseOpacityAnim;

  // Rotación del ícono ⋮ — 90° al abrir el popup, regresa al cerrar
  late final AnimationController _menuCtrl;
  late final Animation<double> _menuRotAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _pulseScaleAnim = Tween<double>(begin: 0.8, end: 1.7).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacityAnim = Tween<double>(
      begin: AppColors.opacitySubtle,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    _menuCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _menuRotAnim = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _menuCtrl, curve: Curves.easeInOut),
    );

    if ((widget.notificationCount ?? 0) > 0) {
      _pulseCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final count = widget.notificationCount ?? 0;
    if (count > 0 && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat();
    } else if (count == 0 && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _menuCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: widget.backgroundColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: widget.showElevation ? AppSizing.elevationMedium : AppSizing.elevationNone,
      centerTitle: false,
      automaticallyImplyLeading: widget.drawerSide == DrawerSide.left,
      leading: _isSearching ? _buildBackButton() : _buildLeading(context),

      title: _isSearching
          ? Container(
              height: AppSizing.buttonHeight - AppSpacing.sm,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: AppColors.opacityHint),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onChanged: widget.onSearch,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox(width: AppSpacing.sm);
                      }
                      return GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          widget.onSearch?.call('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Icon(
                            AppIcons.close,
                            size: AppSizing.iconActionSm,
                            color: colorScheme.onSurface.withValues(alpha: AppColors.opacityHint),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : widget.titleWidget ??
              Text(
                widget.title!,
                style: AppTextStyles.titleLarge.copyWith(color: colorScheme.onPrimary),
              ),

      actions: _isSearching ? null : _buildActions(context),
    );
  }

  // ── Botón back cuando está buscando ─────────────────────────────────────────
  Widget _buildBackButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildActionIcon(
      context,
      icono: Icon(AppIcons.back, color: colorScheme.onPrimary),
      onPressed: _stopSearch,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.drawerSide == DrawerSide.left) return null;
    final buttons = widget.leadingButtons ?? [];
    if (buttons.isEmpty) return null;
    if (buttons.length == 1) return buttons.first;
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  List<Widget>? _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = <Widget>[];

    if (widget.onSearch != null) {
      actions.add(
        _buildActionIcon(
          context,
          icono: Icon(AppIcons.search, color: colorScheme.onPrimary),
          onPressed: _startSearch,
          tooltip: 'Buscar',
        ),
      );
    }

    if (widget.notificationCount != null) {
      actions.add(_buildNotificationIcon(context));
    }

    if (widget.trailingButtons != null) {
      actions.addAll(widget.trailingButtons!);
    }

    if (widget.popupItems != null && widget.popupItems!.isNotEmpty) {
      actions.add(_buildPopupMenu(context));
    }

    if (widget.drawerSide == DrawerSide.right) {
      actions.add(
        Builder(
          builder: (ctx) => _buildActionIcon(
            ctx,
            icono: Icon(AppIcons.menu, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            tooltip: 'Menú',
          ),
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  // ── IconButton con ripple 24% visible sobre fondo oscuro ─────────────────────
  Widget _buildActionIcon(
    BuildContext context, {
    required Widget icono,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: icono,
      onPressed: onPressed,
      tooltip: tooltip,
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.onPrimary.withValues(alpha: AppColors.opacityPressedOnDark);
          }
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
            return colorScheme.onPrimary.withValues(alpha: AppColors.opacityActiveItem);
          }
          return null;
        }),
        shape: const WidgetStatePropertyAll(CircleBorder()),
      ),
    );
  }

  // ── Campana con badge y animación de pulso ───────────────────────────────────
  Widget _buildNotificationIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = widget.notificationCount ?? 0;
    final tieneNotif = count > 0;

    return _buildActionIcon(
      context,
      tooltip: 'Notificaciones',
      onPressed: widget.onNotification ?? () {},
      icono: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            tieneNotif ? AppIcons.notificationFilled : AppIcons.notification,
            color: colorScheme.onPrimary,
            size: AppSizing.iconMd,
          ),
          if (tieneNotif) ...[
            // Anillo exterior — se expande y desvanece (efecto pulso)
            Positioned(
              right: -AppSpacing.xs,
              top: -AppSpacing.xs,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Transform.scale(
                  scale: _pulseScaleAnim.value,
                  child: Opacity(
                    opacity: _pulseOpacityAnim.value,
                    child: Container(
                      width: AppSizing.notifBadgeSize,
                      height: AppSizing.notifBadgeSize,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Badge sólido con número — pill adaptable para 1–99
            Positioned(
              right: -AppSpacing.xs,
              top: -AppSpacing.xs,
              child: Container(
                height: AppSizing.notifBadgeSize,
                constraints: const BoxConstraints(minWidth: AppSizing.notifBadgeSize),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.all(Radius.circular(AppSizing.radiusCircular)),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99' : count.toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnDark,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Popup moderno: bordes redondeados, sombra suave, ícono ⋮ con rotación ────
  Widget _buildPopupMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Más opciones',
      elevation: AppSizing.elevationMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizing.radiusLg)),
      ),
      color: colorScheme.surface,
      onOpened: _menuCtrl.forward,
      onCanceled: _menuCtrl.reverse,
      onSelected: (v) {
        _menuCtrl.reverse();
        widget.onPopupSelected?.call(v);
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: RotationTransition(
          turns: _menuRotAnim,
          child: Icon(AppIcons.more, color: colorScheme.onPrimary, size: AppSizing.iconMd),
        ),
      ),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        for (final item in widget.popupItems!) {
          items.add(
            PopupMenuItem<String>(
              value: item.value,
              child: Row(
                children: [
                  Icon(item.icon, size: AppSizing.iconNav, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(item.label, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          );
          if (item.showDividerAfter) items.add(const PopupMenuDivider());
        }
        return items;
      },
    );
  }
}
