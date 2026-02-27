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
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título como texto
  final String? title;

  /// Título como widget custom (tiene prioridad sobre [title])
  final Widget? titleWidget;

  /// Lado del drawer. [DrawerSide.none] para no mostrar el toggle.
  final DrawerSide drawerSide;

  /// Botones en el lado izquierdo (solo si drawerSide != left)
  final List<Widget>? leadingButtons;

  /// Botones en el lado derecho (antes del popup)
  final List<Widget>? trailingButtons;

  /// Ítems del menú de 3 puntitos. Si está vacío, no se muestra el ícono.
  final List<AppBarPopupItem>? popupItems;

  /// Callback cuando se selecciona un ítem del popup
  final void Function(String value)? onPopupSelected;

  /// Mostrar/ocultar sombra del AppBar
  final bool showElevation;

  /// Color de fondo custom 
  final Color? backgroundColor;

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
  }) : assert(
         title != null || titleWidget != null,
         'CustomAppBar necesita title o titleWidget',
       );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: showElevation ? 4 : 0,
      centerTitle: false,

      // ── TÍTULO ──────────────────────────────────────────────
      title:
          titleWidget ??
          Text(
            title!,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),

      // ── LEADING (izquierda) ──────────────────────────────────
      // Si el drawer está a la IZQUIERDA → Flutter pone el ícono automáticamente
      // Si no hay drawer a la izquierda → podemos poner nuestros leadingButtons
      automaticallyImplyLeading: drawerSide == DrawerSide.left,
      leading: _buildLeading(context),

      // ── ACTIONS (derecha) ────────────────────────────────────
      actions: _buildActions(context),
    );
  }

  /// Construir el lado izquierdo del AppBar
  Widget? _buildLeading(BuildContext context) {
    // Si hay drawer a la izquierda, Flutter lo maneja solo → no interferir
    if (drawerSide == DrawerSide.left) return null;

    // Si hay drawer a la derecha, ponemos los leadingButtons normalmente
    // Si no hay drawer, ídem
    final buttons = leadingButtons ?? [];
    if (buttons.isEmpty) return null;

    if (buttons.length == 1) return buttons.first;

    // Múltiples botones en leading → Row
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  /// Construir el lado derecho del AppBar
  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = <Widget>[];

    // Botones custom de la derecha
    if (trailingButtons != null) {
      actions.addAll(trailingButtons!);
    }

    // 3 puntitos (solo si hay ítems)
    if (popupItems != null && popupItems!.isNotEmpty) {
      actions.add(_buildPopupMenu(context));
    }

    // Drawer a la DERECHA → el ícono va al final de actions
    if (drawerSide == DrawerSide.right) {
      actions.add(
        Builder(
          builder: (ctx) => IconButton(
            icon: Icon(AppIcons.menu, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            tooltip: 'Menú',
          ),
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  /// Construir el menú de 3 puntitos
  Widget _buildPopupMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(AppIcons.more, color: colorScheme.onPrimary),
      tooltip: 'Más opciones',
      onSelected: onPopupSelected,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        for (final item in popupItems!) {
          items.add(
            PopupMenuItem<String>(
              value: item.value,
              child: Row(
                children: [
                  Icon(item.icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(item.label, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          );

          if (item.showDividerAfter) {
            items.add(const PopupMenuDivider());
          }
        }

        return items;
      },
    );
  }
}
