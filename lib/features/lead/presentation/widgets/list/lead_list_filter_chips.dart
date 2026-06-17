// lib/features/lead/presentation/widgets/list/lead_list_filter_chips.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListFilterChips extends StatelessWidget {
  final LeadListFiltro filtroActual;
  final Map<LeadListFiltro, int> conteos;
  final void Function(LeadListFiltro) onFiltroTap;
  final LeadType type;

  const LeadListFilterChips({
    super.key,
    required this.filtroActual,
    required this.conteos,
    required this.onFiltroTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isModerador = SessionService().isModerador;

    final todosChips = [
      (filtro: LeadListFiltro.todos, label: 'Todas'),
      (filtro: LeadListFiltro.misCasos, label: 'Mis casos'),
      (filtro: LeadListFiltro.nuevos, label: 'Nuevos'),
      (filtro: LeadListFiltro.enDesarrollo, label: 'En desarrollo'),
    ];

    final chips = todosChips.where((c) {
      if (c.filtro == LeadListFiltro.todos && !isModerador) return false;
      if (type == LeadType.propuestas &&
          (c.filtro == LeadListFiltro.nuevos ||
              c.filtro == LeadListFiltro.enDesarrollo)) {
        return false;
      }
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: chips.map((chip) {
            final isSelected = filtroActual == chip.filtro;
            final count = conteos[chip.filtro] ?? 0;
            final labelColor = isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onFiltroTap(chip.filtro),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.chipPaddingH,
                    vertical: AppSpacing.chipPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
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
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: chip.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: AppTextStyles.weightSemiBold,
                            color: labelColor,
                          ),
                        ),
                        if (count > 0)
                          TextSpan(
                            text: '  $count',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: AppTextStyles.weightMedium,
                              color: labelColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
