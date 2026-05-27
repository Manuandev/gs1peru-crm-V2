// lib/features/home/presentation/widgets/dashboard/home_menu_cards.dart

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

/// Grid de tarjetas del dashboard con layout flexible.
///
/// [itemsRow] controla cuántas tarjetas caben en cada fila.
/// - La última fila reparte el espacio sobrante entre los items restantes.
/// - Ejemplo: 5 items, itemsRow=3 → fila 1: 3 cards, fila 2: 2 cards
///   (las 2 se reparten el ancho completo).
class HomeMenuCards extends StatelessWidget {
  final HomeLoaded state;

  const HomeMenuCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => _FlexCards(state: state, itemsRow: 2),
      tablet: (context) => _FlexCards(state: state, itemsRow: 3),
      desktop: (context) => _FlexCards(state: state, itemsRow: 4),
    );
  }
}

class _FlexCards extends StatelessWidget {
  final HomeLoaded state;
  final int itemsRow;

  const _FlexCards({required this.state, required this.itemsRow});

  @override
  Widget build(BuildContext context) {
    final items = AppMenuItems.withBadges(
      conversacionesBadge: state.totConversaciones,
      prospectosBadge: state.totProspectos,
      propuestasBadge: state.totPropuestas,
      cobranzaBadge: state.totCobranza,
    );

    // Excluir el item "Inicio" del dashboard
    final dashItems = items.where((i) => i.id != AppRoutes.home).toList();

    // Dividir en filas de [itemsRow] elementos
    final List<List<DrawerItemModel>> rows = [];
    for (int i = 0; i < dashItems.length; i += itemsRow) {
      final end = (i + itemsRow > dashItems.length)
          ? dashItems.length
          : i + itemsRow;
      rows.add(dashItems.sublist(i, end));
    }

    return Column(
      children: [
        for (int r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (int c = 0; c < rows[r].length; c++) ...[
                if (c > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DashboardCard(
                    label: rows[r][c].label,
                    icon: rows[r][c].icon,
                    badge: rows[r][c].badge,
                    onTap: () {
                      final route = rows[r][c].route;
                      if (route != null) context.clearStackAndNavigateTo(route);
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
