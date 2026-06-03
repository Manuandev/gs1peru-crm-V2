// lib/

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

    final allChips = [
      (filtro: LeadListFiltro.todos, label: 'Todas'),
      (filtro: LeadListFiltro.misCasos, label: 'Mis casos'),
      (filtro: LeadListFiltro.nuevos, label: 'Nuevos'),
      (filtro: LeadListFiltro.enDesarrollo, label: 'En desarrollo'),
    ];

    final chips = isModerador
        ? allChips
        : allChips.where((c) => c.filtro != LeadListFiltro.todos).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: chips.map((chip) {
            final isSelected = filtroActual == chip.filtro;
            final count = conteos[chip.filtro] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onFiltroTap(chip.filtro),

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                    // Sombra suave para chips no seleccionados (efecto card)
                    boxShadow: isSelected
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                    border: isSelected
                        ? null
                        : Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                            width: 0.5,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chip.label,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeSm,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        // Badge circular con tamaño mínimo garantizado
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.35)
                                : _badgeColor(chip.filtro),
                            shape: count < 10
                                ? BoxShape
                                      .circle // perfecto círculo para 1 dígito
                                : BoxShape.rectangle,
                            borderRadius: count >= 10
                                ? BorderRadius.circular(11)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _badgeColor(LeadListFiltro filtro) {
    switch (filtro) {
      case LeadListFiltro.todos:
        return Colors.blue;
      case LeadListFiltro.misCasos:
        return Colors.orange;
      case LeadListFiltro.nuevos:
        return Colors.red;
      case LeadListFiltro.enDesarrollo:
        return Colors.green;
    }
  }
}
