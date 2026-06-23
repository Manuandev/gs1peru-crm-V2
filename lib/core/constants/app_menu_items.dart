// lib/core/constants/app_menu_items.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

/// Ítems del menú principal (Drawer y dashboard)
///
/// PROPÓSITO:
/// - Un solo lugar donde viven todos los ítems navegables
/// - Cada pantalla importa de aquí lo que necesita
/// - Si cambia una ruta o un ícono → se cambia SOLO aquí
///
/// NOTA: el drawer ya no consume withBadges() directamente —
/// su estructura está hardcodeada en AppDrawerWidget para soportar
/// la sección condicional por isModerador. withBadges() se usa
/// en HomeMenuCards (dashboard) y otros widgets de contadores.
class AppMenuItems {
  AppMenuItems._();

  // ── Ítem de inicio ─────────────────────────────────────────────────────────

  static const DrawerItemModel home = DrawerItemModel(
    id: AppRoutes.home,
    icon: AppIcons.home,
    label: 'Inicio',
    route: AppRoutes.home,
    showDividerAfter: true,
  );

  // ── Lista estática (sin badges) — para contextos sin estado ────────────────

  static const List<DrawerItemModel> mainItems = [
    home,
    DrawerItemModel(
      id: AppRoutes.chats,
      icon: AppIcons.message,
      label: 'Conversaciones',
      route: AppRoutes.chats,
    ),
    DrawerItemModel(
      id: AppRoutes.seguimiento,
      icon: AppIcons.users,
      label: 'Seguimiento',
      route: AppRoutes.seguimiento,
    ),
    DrawerItemModel(
      id: AppRoutes.contactos,
      icon: AppIcons.documento,
      label: 'Contactos',
      route: AppRoutes.contactos,
    ),
    DrawerItemModel(
      id: AppRoutes.solicitudes,
      icon: AppIcons.email,
      label: 'Solicitudes',
      route: AppRoutes.solicitudes,
    ),
    DrawerItemModel(
      id: AppRoutes.cobranza,
      icon: AppIcons.moneda,
      label: 'Cobranza',
      route: AppRoutes.cobranza,
    ),
  ];

  // ── Con badges dinámicos — usar en HomeMenuCards ────────────────────────────

  static List<DrawerItemModel> withBadges({
    int? conversacionesBadge,
    int? prospectosBadge,
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
        id: AppRoutes.seguimiento,
        icon: AppIcons.users,
        label: 'Seguimiento',
        route: AppRoutes.seguimiento,
        badge: prospectosBadge,
      ),
      DrawerItemModel(
        id: AppRoutes.contactos,
        icon: AppIcons.documento,
        label: 'Contactos',
        route: AppRoutes.contactos,
      ),
      DrawerItemModel(
        id: AppRoutes.solicitudes,
        icon: AppIcons.email,
        label: 'Solicitudes',
        route: AppRoutes.solicitudes,
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
