// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/home/index_home.dart';

class NotificationsPortrait extends StatelessWidget {
  final NotificationsLoaded state;

  const NotificationsPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final empty =
        state.leadsReasignados.isEmpty &&
        state.leadsNuevos.isEmpty &&
        state.recordatorios.isEmpty;

    if (empty) return const _EmptyNotifications();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollapsibleSection(
            icon: Icons.swap_horiz_rounded,
            label: 'Leads Reasignados',
            count: state.totLeadsReasignados,
            children: state.leadsReasignados
                .map((e) => LeadReasignadoTile(lead: e))
                .toList(),
          ),
          CollapsibleSection(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Leads Nuevos',
            count: state.totLeadsNuevos,
            children: state.leadsNuevos
                .map((e) => LeadNuevoTile(lead: e))
                .toList(),
          ),
          CollapsibleSection(
            icon: Icons.notifications_active_rounded,
            label: 'Recordatorios',
            count: state.totRecordatorios,
            children: state.recordatorios
                .map((e) => RecordatorioTile(recordatorio: e))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
