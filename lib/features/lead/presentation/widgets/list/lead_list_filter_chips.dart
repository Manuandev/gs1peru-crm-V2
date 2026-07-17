// lib/features/lead/presentation/widgets/list/lead_list_filter_chips.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListFilterChips extends StatelessWidget {
  final LeadListFiltro filtroActual;
  final Map<LeadListFiltro, int> conteos;
  final void Function(LeadListFiltro) onFiltroTap;

  const LeadListFilterChips({
    super.key,
    required this.filtroActual,
    required this.conteos,
    required this.onFiltroTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CatalogsBloc, CatalogsState>(
      builder: (context, catalogState) {
        if (catalogState is! CatalogsLoaded) return const SizedBox.shrink();

        return _buildChips(context, colorScheme, catalogState);
      },
    );
  }

  Widget _buildChips(
    BuildContext context,
    ColorScheme colorScheme,
    CatalogsLoaded catalogState,
  ) {
    final chips = [
      (
        filtro: LeadListFiltro.todos,
        label: 'Todos',
        icon: AppIcons.filter,
        dotColor: null,
      ),
      (
        filtro: LeadListFiltro.nuevos,
        label: 'Nuevos',
        icon: null,
        dotColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoNuevo),
      ),
      (
        filtro: LeadListFiltro.enDesarrollo,
        label: 'En desarrollo',
        icon: null,
        dotColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoEnDesarrollo),
      ),
      (
        filtro: LeadListFiltro.propuesta,
        label: 'Propuesta',
        icon: null,
        dotColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoConPropuesta),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: chips.map((chip) {
          final isSelected = filtroActual == chip.filtro;
          final count = conteos[chip.filtro] ?? 0;
          final labelColor = isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: GestureDetector(
              onTap: () => onFiltroTap(chip.filtro),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.chipPaddingH,
                  vertical: AppSpacing.chipPaddingV,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                  boxShadow: isSelected
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.black(0.08),
                            blurRadius: AppSizing.shadowBlurSm,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: isSelected
                      ? null
                      : Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          width: AppSizing.borderWidthThin,
                        ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chip.icon != null)
                      Icon(chip.icon, size: AppSizing.iconSm, color: labelColor)
                    else
                      Container(
                        width: AppSizing.dotIndicatorSize,
                        height: AppSizing.dotIndicatorSize,
                        decoration: BoxDecoration(
                          color: chip.dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      count > 0 ? '${chip.label} $count' : chip.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
