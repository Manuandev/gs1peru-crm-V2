// lib/features/lead/presentation/widgets/list/lead_list_stats_row.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Fila de 3 tarjetas resumen: Nuevos / En gestión / Listos para propuesta.
class LeadListStatsRow extends StatelessWidget {
  final Map<LeadListFiltro, int> conteos;

  const LeadListStatsRow({super.key, required this.conteos});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogsBloc, CatalogsState>(
      builder: (context, catalogState) {
        if (catalogState is! CatalogsLoaded) return const SizedBox.shrink();

        return _buildStat(context, catalogState);
      },
    );
  }

  Widget _buildStat(BuildContext context, CatalogsLoaded catalogState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatCard(
                icon: AppSocialUtils.iconoEstado(
                  catalogState.valoresDefecto.idEstadoNuevo,
                ),
                color: AppSocialUtils.colorEstado(
                  catalogState.valoresDefecto.idEstadoNuevo,
                ),
                cantidad: conteos[LeadListFiltro.nuevos] ?? 0,
                label: 'Nuevos',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: AppSocialUtils.iconoEstado(
                  catalogState.valoresDefecto.idEstadoEnDesarrollo,
                ),
                color: AppSocialUtils.colorEstado(
                  catalogState.valoresDefecto.idEstadoEnDesarrollo,
                ),
                cantidad: conteos[LeadListFiltro.enDesarrollo] ?? 0,
                label: 'En desarrollo',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: AppSocialUtils.iconoEstado(
                  catalogState.valoresDefecto.idEstadoConPropuesta,
                ),
                color: AppSocialUtils.colorEstado(
                  catalogState.valoresDefecto.idEstadoConPropuesta,
                ),
                cantidad: conteos[LeadListFiltro.propuesta] ?? 0,
                label: 'Listos para propuesta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  // Object porque el ícono de estado puede venir en FaIconData (FontAwesome,
  // ej. AppSocialUtils.iconoEstado) o en IconData nativo de Flutter — resolveIcon
  // decide cuál FaIcon/Icon armar en tiempo de ejecución.
  final Object icon;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizing.avatarXs,
            height: AppSizing.avatarXs,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: resolveIcon(icon, AppSizing.iconSm, color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                ),
                Text(
                  '$cantidad',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: color,
                  ),
                ),
                Text(
                  'casos',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
