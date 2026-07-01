// lib/features/lead/presentation/widgets/list/lead_list_stats_row.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Fila de 3 tarjetas resumen: Nuevos / En gestión / Listos para propuesta.
class LeadListStatsRow extends StatelessWidget {
  final Map<LeadListFiltro, int> conteos;

  const LeadListStatsRow({super.key, required this.conteos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: AppIcons.message,
              color: AppColors.info,
              cantidad: conteos[LeadListFiltro.nuevos] ?? 0,
              label: 'Nuevos',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              icon: AppIcons.checkCircle,
              color: AppColors.success,
              cantidad: conteos[LeadListFiltro.enDesarrollo] ?? 0,
              label: 'En gestión',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              icon: AppIcons.flag,
              color: AppColors.purple,
              cantidad: conteos[LeadListFiltro.propuesta] ?? 0,
              label: 'Listos para\npropuesta',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int cantidad;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.cantidad,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizing.buttonHeightSmall,
            height: AppSizing.buttonHeightSmall,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: AppSizing.iconActionSm, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$cantidad',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
