// lib/core/constants/app_menu_items.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

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
    icon: AppIcons.homeFilled,
    label: 'Inicio',
    route: AppRoutes.home,
    showDividerAfter: true,
  );

  // ============================================================
  // LISTA COMPLETA EN ORDEN
  // Úsala cuando quieras mostrar todos los módulos
  // ============================================================

  static const List<DrawerItemModel> mainItems = [home];

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
    int? remindersBadge,
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
      ),
      DrawerItemModel(
        id: AppRoutes.recordatorios,
        icon: Icons.alarm_outlined,
        label: 'Recordatorios',
        route: AppRoutes.recordatorios,
        badge: remindersBadge,
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
