// lib/core/constants/app_menu_items.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

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
    icon: AppIcons.home,
    label: 'Inicio',
    route: AppRoutes.home,
    showDividerAfter: true,
  );

  // ============================================================
  // LISTA COMPLETA EN ORDEN
  // Úsala cuando quieras mostrar todos los módulos
  // ============================================================

  // static const List<DrawerItemModel> mainItems = [home];

  static const List<DrawerItemModel> mainItems = [
    home,
    DrawerItemModel(
      id: AppRoutes.chats,
      icon: AppIcons.message,
      label: 'Conversaciones',
      route: AppRoutes.chats,
    ),
    DrawerItemModel(
      id: AppRoutes.prospectos,
      icon: AppIcons.user,
      label: 'Prospectos',
      route: AppRoutes.prospectos,
    ),
    DrawerItemModel(
      id: AppRoutes.propuestas,
      icon: AppIcons.fileOutlined,
      label: 'Propuestas',
      route: AppRoutes.propuestas,
    ),
    DrawerItemModel(
      id: AppRoutes.cobranza,
      icon: AppIcons.moneda,
      label: 'Cobranza',
      route: AppRoutes.cobranza,
    ),
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
    int? conversacionesBadge,
    int? prospectosBadge,
    int? propuestasBadge,
    int? cobranzaBadge,
  }) {
    return [
      home,
      DrawerItemModel(
        id: AppRoutes.chats,
        icon: AppIcons.message,
        label: 'Conversaciones',
        route: AppRoutes.chats,
        badge: conversacionesBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.prospectos,
        icon: AppIcons.user,
        label: 'Prospectos',
        route: AppRoutes.prospectos,
        badge: prospectosBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.propuestas,
        icon: AppIcons.fileOutlined,
        label: 'Propuestas',
        route: AppRoutes.propuestas,
        badge: propuestasBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.cobranza,
        icon: AppIcons.moneda,
        label: 'Cobranza',
        route: AppRoutes.cobranza,
        badge: cobranzaBadge,
      ),
    ];
  }
}
