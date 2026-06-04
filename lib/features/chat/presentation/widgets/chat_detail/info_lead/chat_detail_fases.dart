import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailFases extends StatelessWidget {
  final String idEstadoActual;
  final void Function(LeadEstado estado) onEstadoTap;

  const ChatDetailFases({
    super.key,
    required this.idEstadoActual,
    required this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fase del lead', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: LeadEstado.values.map((estado) {
              final isActivo = estado.id == idEstadoActual;
              final isUltimo = estado == LeadEstado.values.last;

              return Expanded(
                child: Row(
                  children: [
                    // ── Círculo + label ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onEstadoTap(estado),
                        child: Column(
                          children: [
                            Container(
                              width: AppSizing.faseIndicatorSize,
                              height: AppSizing.faseIndicatorSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActivo
                                    ? AppColors.success
                                    : AppColors.transparent,
                                border: Border.all(
                                  color: isActivo
                                      ? AppColors.success
                                      : AppColors.grey400,
                                  width: AppSizing.borderFocusWidth,
                                ),
                              ),
                              child: isActivo
                                  ? const Icon(
                                      AppIcons.circuloRelleno,
                                      color: AppColors.textOnDark,
                                      size: AppSizing.indicatorDotSize,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              estado.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isActivo
                                    ? AppColors.success
                                    : AppColors.grey600,
                                fontWeight: isActivo
                                    ? AppTextStyles.weightBold
                                    : AppTextStyles.weightRegular,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Línea conectora ──
                    if (!isUltimo)
                      Expanded(
                        child: Container(
                          height: AppSizing.borderFocusWidth,
                          margin: const EdgeInsets.only(bottom: AppSpacing.mdLg),
                          color: AppColors.grey300,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
