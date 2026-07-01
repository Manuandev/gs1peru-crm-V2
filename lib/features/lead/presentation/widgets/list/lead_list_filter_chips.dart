// lib/features/lead/presentation/widgets/list/lead_list_filter_chips.dart

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
    final isModerador = SessionService().isModerador;

    final todosChips = [
      (filtro: LeadListFiltro.todos, label: 'Todos'),
      (filtro: LeadListFiltro.misCasos, label: 'Mis casos'),
      (filtro: LeadListFiltro.nuevos, label: 'Nuevos'),
      (filtro: LeadListFiltro.enDesarrollo, label: 'En desarrollo'),
      (filtro: LeadListFiltro.propuesta, label: 'Propuesta'),
    ];

    // El chip "Todos" solo lo ve el moderador
    final chips = todosChips
        .where((c) => !(c.filtro == LeadListFiltro.todos && !isModerador))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: chips.map((chip) {
          final isSelected = filtroActual == chip.filtro;
          final count = conteos[chip.filtro] ?? 0;
          final labelColor =
              isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: GestureDetector(
                onTap: () => onFiltroTap(chip.filtro),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
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
                  child: Text(
                    count > 0 ? '${chip.label} $count' : chip.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
