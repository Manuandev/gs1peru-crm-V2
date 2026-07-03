// lib/features/chat/presentation/widgets/chat_detail/chat_detail_app_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailAppBar extends StatelessWidget {
  final Lead lead;
  final String? fechaUltimaRespuesta;
  final int idCanal;
  final VoidCallback? onTap;

  const ChatDetailAppBar({
    super.key,
    required this.lead,
    required this.idCanal,
    this.fechaUltimaRespuesta,
    this.onTap,
  });

  Duration? _elapsedTime() {
    if (fechaUltimaRespuesta == null || fechaUltimaRespuesta!.isEmpty) {
      return null;
    }
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
        // ── Avatar con badge de canal ──
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: AppSizing.avatarRadiusAppBar,
              backgroundColor: AvatarUtils.color(lead.nombreCompleto),
              child: Icon(
                AppIcons.user,
                size: AppSizing.iconMd,
                color: AppColors.textOnDark,
              ),
            ),
            if (idCanal > 0)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: AppSizing.avatarCanalBadge,
                  height: AppSizing.avatarCanalBadge,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: AppSizing.canalBadgeBorder,
                    ),
                  ),
                  child: Center(
                    child: AppSocialUtils.widgetCanalById(
                      idCanal,
                      size: AppSizing.iconCanalBadge,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.smPlus),

        // ── Nombre + canal + estado ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre clickeable → EditLead
              GestureDetector(
                onTap: onTap,
                child: Text(
                  lead.nombreCompleto,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Campaña / canal — oculto si no hay lead asociado (sin canal)
              if (lead.idLead > 0)
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
                    Expanded(
                      child: Text(
                        lead.canal.isEmpty ? 'Sin canal' : lead.canal,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: colorScheme.onPrimary.withValues(
                            alpha: AppColors.opacityOnPrimarySubtle,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              // Punto verde + "Derivado por IA · Última respuesta hace X"
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.brandForest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      elapsed != null
                          ? 'Derivado por IA · Última respuesta hace ${ElapsedTimeUtils.formatHyM(elapsed)}'
                          : 'Derivado por IA',
                      style: AppTextStyles.labelVerySmall8.copyWith(
                        color: colorScheme.onPrimary.withValues(
                          alpha: AppColors.opacityOnPrimarySubtle,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
