// lib/features/home/presentation/widgets/dashboard/home_menu_cards.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:flutter/material.dart';

// lib/features/home/presentation/widgets/dashboard/home_menu_cards.dart

class HomeMenuCards extends StatelessWidget {
  final int inboxCount;
  final int leadsCount;
  final int recordatoriosCount;

  const HomeMenuCards({
    super.key,
    required this.inboxCount,
    required this.leadsCount,
    required this.recordatoriosCount,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => _MobileCards(
        inboxCount: inboxCount,
        leadsCount: leadsCount,
        recordatoriosCount: recordatoriosCount,
      ),
      tablet: (context) => _GridCards(
        inboxCount: inboxCount,
        leadsCount: leadsCount,
        recordatoriosCount: recordatoriosCount,
        crossAxisCount: 3,
      ),
      desktop: (context) => _GridCards(
        inboxCount: inboxCount,
        leadsCount: leadsCount,
        recordatoriosCount: recordatoriosCount,
        crossAxisCount: 4,
      ),
    );
  }
}

class _MobileCards extends StatelessWidget {
  final int inboxCount;
  final int leadsCount;
  final int recordatoriosCount;

  const _MobileCards({
    required this.inboxCount,
    required this.leadsCount,
    required this.recordatoriosCount,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para saber el espacio real disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        // El alto total del grid es proporcional al ancho disponible
        // aspect ratio 2.8 : funciona bien en móviles pequeños y grandes
        final totalHeight = constraints.maxWidth / 2.8;
        final rowTopHeight = totalHeight * 0.62;
        final rowBottomHeight = totalHeight * 0.35;

        return Column(
          children: [
            Row();
            ],
        );
      },
    );
  }
}

class _GridCards extends StatelessWidget {
  final int inboxCount;
  final int leadsCount;
  final int recordatoriosCount;
  final int crossAxisCount;

  const _GridCards({
    required this.inboxCount,
    required this.leadsCount,
    required this.recordatoriosCount,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = AppMenuItems.withBadges();
      

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: ResponsiveHelper.getValue(
          context,
          mobile: 2.4,
          tablet: 2.8,
          desktop: 3.2,
        ),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardCard(
          label: item.label,
          icon: item.icon,
          color: item.color,
          badge: item.badge,
          onTap: () {},
        );
      },
    );
  }
}
