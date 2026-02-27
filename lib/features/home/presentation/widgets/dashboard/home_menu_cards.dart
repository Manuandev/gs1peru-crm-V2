// lib/features/home/presentation/widgets/dashboard/home_menu_cards.dart

import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:app_crm/core/utils/responsive_helper.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/dashboard_home.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';

// lib/features/home/presentation/widgets/dashboard/home_menu_cards.dart

class HomeMenuCards extends StatelessWidget {
  final int inboxCount;
  final int recordatoriosCount;

  const HomeMenuCards({
    super.key,
    required this.inboxCount,
    required this.recordatoriosCount,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => _MobileCards(
        inboxCount: inboxCount,
        recordatoriosCount: recordatoriosCount,
      ),
      tablet: (context) => _GridCards(
        inboxCount: inboxCount,
        recordatoriosCount: recordatoriosCount,
        crossAxisCount: 3,
      ),
      desktop: (context) => _GridCards(
        inboxCount: inboxCount,
        recordatoriosCount: recordatoriosCount,
        crossAxisCount: 4,
      ),
    );
  }
}

class _MobileCards extends StatelessWidget {
  final int inboxCount;
  final int recordatoriosCount;

  const _MobileCards({
    required this.inboxCount,
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
            // ── FILA 1: inbox grande + 2 pequeñas ──────────
            SizedBox(
              height: rowTopHeight,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DashboardCard(
                      label: 'Inbox',
                      icon: Icons.chat_bubble_outline,
                      color: Colors.blue,
                      badge: inboxCount,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    flex: 2,
                    child: DashboardCard(
                      label: 'Mis leads',
                      icon: Icons.person_outline,
                      color: Colors.deepOrange,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xs),

            // ── FILA 2: 2 cards iguales ──────────────────
            SizedBox(
              height: rowBottomHeight,
              child: Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      label: 'Recordatorios',
                      icon: Icons.access_time,
                      color: Colors.green,
                      badge: recordatoriosCount,
                      onTap: context.goToRecordatorios,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: DashboardCard(
                      label: 'Cobranza',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GridCards extends StatelessWidget {
  final int inboxCount;
  final int recordatoriosCount;
  final int crossAxisCount;

  const _GridCards({
    required this.inboxCount,
    required this.recordatoriosCount,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _CardData(
        'Inbox',
        Icons.chat_bubble_outline,
        Colors.blue,
        badge: inboxCount,
      ),
      _CardData('Mis Leads', Icons.person, Colors.orange),
      _CardData('Leads', Icons.person_outline, Colors.deepOrange),
      _CardData(
        'Recordatorios',
        Icons.access_time,
        Colors.green,
        badge: recordatoriosCount,
      ),
      _CardData('Cobranza', Icons.attach_money, Colors.purple),
    ];

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

class _CardData {
  final String label;
  final IconData icon;
  final Color color;
  final int? badge;
  _CardData(this.label, this.icon, this.color, {this.badge});
}
