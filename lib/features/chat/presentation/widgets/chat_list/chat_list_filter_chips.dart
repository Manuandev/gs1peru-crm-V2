// lib/features/chat/presentation/widgets/chat_list/chat_list_filter_chips.dart

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
      (filtro: ChatListFiltro.conPropuesta, label: 'Con propuesta'),
      (filtro: ChatListFiltro.enCobranza, label: 'En cobranza'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: chips.map((chip) {
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
                      if (_mostrarBadge(chip.filtro))
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.white(0.6)
                                : _badgeColor(chip.filtro),
                            shape: BoxShape.circle,
                          ),
                        ),
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

  bool _mostrarBadge(ChatListFiltro filtro) {
    return switch (filtro) {
      ChatListFiltro.todos => false,
      ChatListFiltro.sinResponder => false,
      _ => true,
    };
  }

  Color _badgeColor(ChatListFiltro filtro) {
    return switch (filtro) {
      ChatListFiltro.sinResponder => AppColors.secondary,
      ChatListFiltro.enDesarrollo => AppColors.success,
      ChatListFiltro.conPropuesta => AppColors.info,
      ChatListFiltro.enCobranza => AppColors.secondary,
      ChatListFiltro.todos => AppColors.secondary,
    };
  }
}
