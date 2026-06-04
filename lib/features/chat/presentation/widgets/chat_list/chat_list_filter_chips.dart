// lib/

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListFilterChips extends StatelessWidget {
  final ChatListFiltro filtroActual;
  final Map<ChatListFiltro, int> conteos;
  final void Function(ChatListFiltro) onFiltroTap;

  const ChatListFilterChips({
    super.key,
    required this.filtroActual,
    required this.conteos,
    required this.onFiltroTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final chips = [
      (filtro: ChatListFiltro.todos, label: 'Todas'),
      (filtro: ChatListFiltro.sinResponder, label: 'Sin responder'),
      (filtro: ChatListFiltro.enDesarrollo, label: 'En desarrollo'),
    ];

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
                    horizontal: AppSpacing.chipPaddingH,
                    vertical: AppSpacing.chipPaddingV,
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
                      Text(
                        chip.label,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeSm,
                          fontWeight: AppTextStyles.weightSemiBold,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: AppSpacing.chipGap),
                        // Badge circular con tamaño mínimo garantizado
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: AppSizing.mensajesBadgeSize,
                            minHeight: AppSizing.mensajesBadgeSize,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.chipGap,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.white(0.35)
                                : _badgeColor(chip.filtro),
                            shape: count < 10
                                ? BoxShape
                                      .circle // perfecto círculo para 1 dígito
                                : BoxShape.rectangle,
                            borderRadius: count >= 10
                                ? BorderRadius.circular(AppSizing.radiusCircular)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: AppTextStyles.weightBold,
                                color: AppColors.textOnDark,
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

  Color _badgeColor(ChatListFiltro filtro) {
    switch (filtro) {
      case ChatListFiltro.sinResponder:
        return AppColors.error;
      case ChatListFiltro.enDesarrollo:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}
