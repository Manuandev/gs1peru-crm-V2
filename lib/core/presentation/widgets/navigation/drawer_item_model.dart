// lib/core/presentation/widgets/navigation/drawer_item_model.dart

import 'package:flutter/material.dart';

/// Lado donde aparece el Drawer
enum DrawerSide { left, right, none }

/// Modelo que representa un ítem del Drawer
///
/// USO:
/// DrawerItemModel(
///   id: AppRoutes.leads,
///   icon: Icons.people_outline,
///   label: 'Leads',
/// )
///
/// Con acción custom (sin navegar):
/// DrawerItemModel(
///   id: 'logout',
///   icon: Icons.logout,
///   label: 'Cerrar sesión',
///   onTap: () => context.logout(),
/// )
class DrawerItemModel {
  /// Identificador único — generalmente el nombre de la ruta (AppRoutes.x)
  /// Se usa para saber cuál ítem está activo.
  final String id;

  /// Ícono del ítem
  final IconData icon;

  /// Etiqueta visible
  final String label;

  /// Ruta a navegar. Si es null, se usa [onTap].
  final String? route;

  /// Acción custom. Si se define, tiene prioridad sobre [route].
  final VoidCallback? onTap;

  /// Muestra una línea divisoria después de este ítem
  final bool showDividerAfter;

  /// Badge numérico (notificaciones, contadores)
  final int? badge;

  const DrawerItemModel({
    required this.id,
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
    this.showDividerAfter = false,
    this.badge,
  }) : assert(
          route != null || onTap != null,
          'DrawerItemModel necesita route o onTap',
        );
}

/// Modelo para el PopupMenu del AppBar (3 puntitos)
///
/// USO:
/// AppBarPopupItem(
///   value: 'actualizar',
///   icon: Icons.refresh,
///   label: 'Actualizar',
/// )
class AppBarPopupItem {
  final String value;
  final IconData icon;
  final String label;
  final bool showDividerAfter;

  const AppBarPopupItem({
    required this.value,
    required this.icon,
    required this.label,
    this.showDividerAfter = false,
  });
}
