// lib/features/home/presentation/pages/base_page.dart

import 'package:app_crm/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_menu_items.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/core/presentation/widgets/navigation/app_drawer_widget.dart';
import 'package:app_crm/core/presentation/widgets/navigation/custom_app_bar.dart';
import 'package:app_crm/core/presentation/widgets/navigation/drawer_item_model.dart';

/// BasePage — Página base para todas las pantallas del home
///
/// PROPÓSITO:
/// - Punto único de armado de layout: AppBar + Drawer + Body + Footer
/// - Cada pantalla del módulo usa BasePage y solo le pasa su body
/// - Toda la configuración de AppBar y Drawer se hace aquí
///
/// USO BÁSICO:
/// ```dart
/// class LeadsPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BasePage(
///       title: 'Leads',
///       body: LeadsView(),
///     );
///   }
/// }
/// ```
///
/// USO AVANZADO:
/// ```dart
/// BasePage(
///   title: 'Leads',
///   drawerSide: DrawerSide.left,
///   drawerItems: [
///     DrawerItemModel(id: AppRoutes.leads, icon: Icons.people, label: 'Leads'),
///   ],
///   drawerHeader: MyDrawerHeader(user: currentUser),
///   appBarTrailingButtons: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
///   appBarPopupItems: [
///     AppBarPopupItem(value: 'refresh', icon: Icons.refresh, label: 'Actualizar'),
///   ],
///   onPopupSelected: (value) { ... },
///   footer: MyFooterWidget(),
///   body: LeadsView(),
/// )
/// ```
class BasePage extends StatelessWidget {
  // ── APPBAR ───────────────────────────────────────────────────

  /// Título de la pantalla (texto)
  final String? title;

  /// Título como widget custom (tiene prioridad sobre [title])
  final Widget? titleWidget;

  /// Lado del drawer: left, right, none
  final DrawerSide drawerSide;

  /// Botones en la izquierda del AppBar
  /// (Solo funciona si drawerSide != DrawerSide.left)
  final List<Widget>? appBarLeadingButtons;

  /// Botones en la derecha del AppBar (antes del popup)
  final List<Widget>? appBarTrailingButtons;

  /// Ítems del menú de 3 puntitos
  final List<AppBarPopupItem>? appBarPopupItems;

  /// Callback cuando se selecciona un ítem del popup
  final void Function(String value)? onPopupSelected;

  /// Mostrar sombra en el AppBar
  final bool showAppBarElevation;

  /// Color de fondo del AppBar
  final Color? appBarBackgroundColor;

  // ── DRAWER ───────────────────────────────────────────────────

  /// Ítems del drawer. Si es null o vacío, solo se ven configuración y logout.
  final List<DrawerItemModel>? drawerItems;

  /// Header del drawer (avatar, nombre, etc.)
  /// Pasa null para ocultarlo completamente.
  final Widget? drawerHeader;

  /// Callback custom para logout
  final VoidCallback? onLogout;

  /// Callback custom para configuración
  final VoidCallback? onSettings;

  /// Ocultar el ítem de configuración
  final bool showDrawerSettings;

  /// Ocultar el ítem de cerrar sesión
  final bool showDrawerLogout;

  // ── BODY ─────────────────────────────────────────────────────

  /// Contenido principal de la pantalla
  final Widget body;

  /// Widget fijo al fondo (footer). null para no mostrar.
  final Widget? footer;

  /// FloatingActionButton
  final Widget? floatingActionButton;

  /// Posición del FAB
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Color de fondo del Scaffold (null = usa el del tema)
  final Color? backgroundColor;

  /// Padding del body. null para sin padding.
  final EdgeInsetsGeometry? bodyPadding;

  const BasePage({
    super.key,
    // AppBar
    this.title,
    this.titleWidget,
    this.drawerSide = DrawerSide.left,
    this.appBarLeadingButtons,
    this.appBarTrailingButtons,
    this.appBarPopupItems,
    this.onPopupSelected,
    this.showAppBarElevation = false,
    this.appBarBackgroundColor,
    // Drawer
    this.drawerItems,
    this.drawerHeader,
    this.onLogout,
    this.onSettings,
    this.showDrawerSettings = true,
    this.showDrawerLogout = true,
    // Body
    required this.body,
    this.footer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.bodyPadding,
  }) : assert(
         title != null || titleWidget != null,
         'BasePage necesita title o titleWidget',
       );

  @override
  Widget build(BuildContext context) {
    // Construir el drawer (solo si drawerSide != none)
    final Widget? drawer = drawerSide != DrawerSide.none
        ? AppDrawerWidget(
            items: drawerItems ?? AppMenuItems.mainItems,
            // onLogout: onLogout,
            onSettings: onSettings,
            showSettings: showDrawerSettings,
            showLogout: showDrawerLogout,
          )
        : null;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ── APP BAR ────────────────────────────────────────────
      appBar: CustomAppBar(
        title: title,
        titleWidget: titleWidget,
        drawerSide: drawerSide,
        leadingButtons: appBarLeadingButtons,
        trailingButtons: appBarTrailingButtons,
        popupItems: appBarPopupItems,
        onPopupSelected: onPopupSelected,
        showElevation: showAppBarElevation,
        backgroundColor: appBarBackgroundColor,
      ),

      // ── DRAWER ─────────────────────────────────────────────
      // left drawer → drawer
      drawer: drawerSide == DrawerSide.left ? drawer : null,

      // right drawer → endDrawer
      endDrawer: drawerSide == DrawerSide.right ? drawer : null,

      // ── BODY + FOOTER ──────────────────────────────────────
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final orientation = MediaQuery.of(context).orientation;
            final isLandscape = orientation == Orientation.landscape;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: bodyPadding ?? EdgeInsets.zero,
                    child: body,
                  ),
                ),

                // Footer automático pero RESPONSIVE
                if (!isLandscape)
                  footer ?? const _FooterPages()
                else
                  _FooterCompact(),
              ],
            );
          },
        ),
      ),

      // ── FAB ────────────────────────────────────────────────
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

// ============================================================
// DrawerHeader listo para usar — puedes pasarlo directamente
// o crear el tuyo propio.
// ============================================================

/// Header prediseñado para el Drawer con avatar, nombre y subtítulo.
///
/// USO:
/// drawerHeader: DrawerUserHeader(
///   name: 'Juan Pérez',
///   subtitle: 'juan@empresa.com',
///   avatarUrl: 'https://...',   // o null para ícono por defecto
/// )

class _FooterPages extends StatelessWidget {
  const _FooterPages();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Text(
        '${AppConstants.nombreApp} - v${AppConstants.version}',
        style: AppTextStyles.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FooterCompact extends StatelessWidget {
  const _FooterCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4, // más chico que AppSpacing.sm
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Text(
        '${AppConstants.nombreApp} - v${AppConstants.version}',
        style: AppTextStyles.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
