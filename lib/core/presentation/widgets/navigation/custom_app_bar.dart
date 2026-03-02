// lib/core/presentation/widgets/navigation/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'drawer_item_model.dart';

/// CustomAppBar — AppBar completamente personalizable
///
/// CARACTERÍSTICAS:
/// - Drawer a la izquierda O derecha (nunca los dos)
/// - Botones a la izquierda y/o derecha (respetan posición del drawer)
/// - Menú de 3 puntitos estilo WhatsApp con ítems configurables
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
///   trailingButtons: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
///   popupItems: [
///     AppBarPopupItem(value: 'refresh', icon: Icons.refresh, label: 'Actualizar'),
///   ],
///   onPopupSelected: (value) { ... },
/// )
// lib/core/presentation/widgets/navigation/custom_app_bar.dart

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

  // ✅ Nuevo — si no es null, aparece el ícono de búsqueda
  final void Function(String query)? onSearch;

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
  }) : assert(
         title != null || titleWidget != null,
         'CustomAppBar necesita title o titleWidget',
       );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    widget.onSearch?.call(''); // limpia resultados
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: widget.backgroundColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: widget.showElevation ? 4 : 0,
      centerTitle: false,
      automaticallyImplyLeading: widget.drawerSide == DrawerSide.left,
      leading: _isSearching ? _buildBackButton() : _buildLeading(context),

      // ── TÍTULO o CAMPO DE BÚSQUEDA ───────────────────────────
      title: _isSearching
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(
                          // ignore: deprecated_member_use
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                      onChanged: widget.onSearch,
                    ),
                  ),
                  // ✅ X dentro del container
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, _) {
                      if (value.text.isEmpty) return const SizedBox(width: 8);
                      return GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          widget.onSearch?.call('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            // ignore: deprecated_member_use
                            color: colorScheme.onSurface.withOpacity(0.5),
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
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),

      actions: _isSearching ? null : _buildActions(context),
    );
  }

  // ── Botón back cuando está buscando ─────────────────────────
  Widget _buildBackButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
      onPressed: _stopSearch,
    );
  }

  // ── Botón X para limpiar texto ───────────────────────────────
  // Widget _buildClearButton() {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   return IconButton(
  //     icon: Icon(Icons.close, color: colorScheme.onPrimary),
  //     onPressed: () {
  //       _searchController.clear();
  //       widget.onSearch?.call('');
  //     },
  //   );
  // }

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

    // ✅ Ícono de búsqueda — solo si onSearch está definido
    if (widget.onSearch != null) {
      actions.add(
        IconButton(
          icon: Icon(Icons.search, color: colorScheme.onPrimary),
          onPressed: _startSearch,
        ),
      );
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
          builder: (ctx) => IconButton(
            icon: Icon(AppIcons.menu, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  Widget _buildPopupMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(AppIcons.more, color: colorScheme.onPrimary),
      tooltip: 'Más opciones',
      onSelected: widget.onPopupSelected,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        for (final item in widget.popupItems!) {
          items.add(
            PopupMenuItem<String>(
              value: item.value,
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: colorScheme.onSurface),
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
