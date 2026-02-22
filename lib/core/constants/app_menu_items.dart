// lib/core/constants/app_menu_items.dart

import 'package:flutter/material.dart';
import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/core/presentation/widgets/navigation/drawer_item_model.dart';

/// Ítems del menú principal (Drawer)
///
/// PROPÓSITO:
/// - Un solo lugar donde viven todos los ítems del drawer
/// - Cada pantalla importa de aquí lo que necesita
/// - Si cambia una ruta o un ícono → se cambia SOLO aquí
///
/// USO en home_page.dart:
/// drawerItems: AppMenuItems.mainItems,
///
/// USO con badge dinámico (ej: chats con 3 mensajes):
/// drawerItems: AppMenuItems.withBadges(chatsBadge: 3),
class AppMenuItems {
  AppMenuItems._();

  // ============================================================
  // ÍTEMS PRINCIPALES
  // Orden en que aparecen en el drawer
  // ============================================================

  static const DrawerItemModel home = DrawerItemModel(
    id: AppRoutes.home,
    icon: Icons.home_outlined,
    label: 'Inicio',
    route: AppRoutes.home,
    showDividerAfter: true,
  );

  static const DrawerItemModel leads = DrawerItemModel(
    id: AppRoutes.leads,
    icon: Icons.people_outline,
    label: 'Leads',
    route: AppRoutes.leads,
    // showDividerAfter: true, // separador visual después de leads
  );

  static const DrawerItemModel recordatorios = DrawerItemModel(
    id: AppRoutes.recordatorios,
    icon: Icons.alarm_outlined,
    label: 'Recordatorios',
    route: AppRoutes.recordatorios,
  );

  static const DrawerItemModel chats = DrawerItemModel(
    id: AppRoutes.chats,
    icon: Icons.chat_bubble_outline,
    label: 'Chats',
    route: AppRoutes.chats,
  );

  static const DrawerItemModel cobranza = DrawerItemModel(
    id: AppRoutes.cobranza,
    icon: Icons.payments_outlined,
    label: 'Cobranza',
    route: AppRoutes.cobranza,
  );

  // ============================================================
  // LISTA COMPLETA EN ORDEN
  // Úsala cuando quieras mostrar todos los módulos
  // ============================================================

  static const List<DrawerItemModel> mainItems = [
    home,
    leads,
    recordatorios,
    chats,
    cobranza,
  ];

  // ============================================================
  // CON BADGES DINÁMICOS
  // Úsala cuando tengas contadores en tiempo real
  //
  // USO:
  // drawerItems: AppMenuItems.withBadges(
  //   chatsBadge: unreadMessages,
  //   recordatoriosBadge: pendingReminders,
  // ),
  // ============================================================

  static List<DrawerItemModel> withBadges({
    int? chatsBadge,
    int? recordatoriosBadge,
    int? leadsBadge,
    int? cobranzaBadge,
  }) {
    return [
      home,
      DrawerItemModel(
        id: AppRoutes.leads,
        icon: Icons.people_outline,
        label: 'Leads',
        route: AppRoutes.leads,
        badge: leadsBadge,
        showDividerAfter: true,
      ),
      DrawerItemModel(
        id: AppRoutes.recordatorios,
        icon: Icons.alarm_outlined,
        label: 'Recordatorios',
        route: AppRoutes.recordatorios,
        badge: recordatoriosBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.chats,
        icon: Icons.chat_bubble_outline,
        label: 'Chats',
        route: AppRoutes.chats,
        badge: chatsBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.cobranza,
        icon: Icons.payments_outlined,
        label: 'Cobranza',
        route: AppRoutes.cobranza,
        badge: cobranzaBadge,
      ),
    ];
  }
}
