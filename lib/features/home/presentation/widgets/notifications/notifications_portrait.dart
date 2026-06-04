// lib/features/home/presentation/widgets/notifications/notifications_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
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
            icon: AppIcons.reasignar,
            label: 'Leads Reasignados',
            count: state.totLeadsReasignados,
            children: state.leadsReasignados
                .map((e) => LeadReasignadoTile(lead: e))
                .toList(),
          ),
          CollapsibleSection(
            icon: AppIcons.leadNuevo,
            label: 'Leads Nuevos',
            count: state.totLeadsNuevos,
            children: state.leadsNuevos
                .map((e) => LeadNuevoTile(lead: e))
                .toList(),
          ),
          CollapsibleSection(
            icon: AppIcons.notificationActive,
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
      padding: const EdgeInsets.only(top: AppSpacing.emptyStateTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.notificationOff,
            size: AppSizing.iconXl,
            color: colorScheme.onSurface.withValues(
              alpha: AppColors.opacityDivider,
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'No tienes notificaciones',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: AppColors.opacityEmptyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
