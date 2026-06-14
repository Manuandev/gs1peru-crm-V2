// lib/features/cobranza/presentation/widgets/lista/cobranza_filter_chips.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFilterChips extends StatelessWidget {
  final CobranzaChipFiltro filtroActual;
  final void Function(CobranzaChipFiltro) onFiltroTap;

  const CobranzaFilterChips({
    super.key,
    required this.filtroActual,
    required this.onFiltroTap,
  });

  static const _chips = [
    (filtro: CobranzaChipFiltro.todos, label: 'Todos'),
    (filtro: CobranzaChipFiltro.misCasos, label: 'Mis casos'),
    (filtro: CobranzaChipFiltro.contado, label: 'Contado'),
    (filtro: CobranzaChipFiltro.credito, label: 'Crédito'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: _chips.map((chip) {
            final isSelected = filtroActual == chip.filtro;

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
                  child: Text(
                    chip.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
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
