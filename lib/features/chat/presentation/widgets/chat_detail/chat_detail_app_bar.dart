// lib/features/chat/presentation/widgets/chat_detail/chat_detail_app_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailAppBar extends StatelessWidget {
  final Lead lead;
  final String? fechaUltimaRespuesta;
  const ChatDetailAppBar({super.key, required this.lead, this.fechaUltimaRespuesta});

  Duration? _elapsedTime() {
    if (fechaUltimaRespuesta == null || fechaUltimaRespuesta!.isEmpty) return null;
    final fecha = DateTime.tryParse(fechaUltimaRespuesta!.trim());
    if (fecha == null) return null;
    final elapsed = DateTime.now().difference(fecha);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final elapsed = _elapsedTime();

    return Row(
      children: [
        // ── Avatar con iniciales ──
        CircleAvatar(
          radius: AppSizing.avatarRadiusAppBar,
          backgroundColor: lead.nombreCompleto.avatarColor,
          child: Text(
            lead.nombreCompleto.initials,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: AppColors.textOnDark,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.smPlus),

        // ── Nombre + canal ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lead.nombreCompleto,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: AppTextStyles.weightBold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(
                    AppIcons.campaign,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onPrimary.withValues(
                      alpha: AppColors.opacityOnPrimarySubtle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    lead.canal.isEmpty ? 'Sin canal' : lead.canal,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onPrimary.withValues(
                        alpha: AppColors.opacityOnPrimarySubtle,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.brandForest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (elapsed != null) ...[
                    Text(
                      'Última respuesta hace ${ElapsedTimeUtils.formatHyM(elapsed)}',
                      style: AppTextStyles.labelVerySmall8.copyWith(
                        color: ElapsedTimeUtils.colorFromElapsed(elapsed),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
