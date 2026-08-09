// lib/features/lead/presentation/widgets/contacto_detalle/proximo_recordatorio_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Card "Próximo recordatorio" en la pestaña Información — solo se muestra
/// si el recordatorio más próximo (RecordatoriosLeadCubit, ya ordenado
/// ascendente por el SP 'LRN') está a 30 minutos o menos de la hora actual.
/// Pedido de negocio: a las 12:30 SÍ se muestra un recordatorio de la 1:00pm
/// (30 min de anticipación), a las 12:00 (60 min) todavía NO.
/// "Ver todos" salta al tab "Recordatorios" (índice 3) del mismo
/// DefaultTabController que arma _ContactoScaffold.
class ProximoRecordatorioCard extends StatelessWidget {
  static const _minutosAnticipacion = 30;

  const ProximoRecordatorioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordatoriosLeadCubit, RecordatoriosLeadState>(
      builder: (context, state) {
        if (state is! RecordatoriosLeadSuccess ||
            state.recordatorios.isEmpty) {
          return const SizedBox.shrink();
        }

        final proximo = state.recordatorios.first;
        final fecha = DateFormatter.parseDate(
          proximo.fechaRecordatorio.trim(),
        );
        if (fecha == null) return const SizedBox.shrink();

        final faltan = fecha.difference(DateTime.now());
        if (faltan.isNegative || faltan.inMinutes > _minutosAnticipacion) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: AppSizing.shadowBlurMd,
                  offset: const Offset(0, AppSizing.shadowOffsetCardY),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      AppIcons.recordatorio,
                      size: AppSizing.iconXs,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'PRÓXIMO RECORDATORIO',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: AppTextStyles.weightBold,
                        letterSpacing: AppTextStyles.letterSpacingNarrow,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => DefaultTabController.of(
                        context,
                      ).animateTo(3),
                      child: Text(
                        'Ver todos',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LeadRecordatorioContent(recordatorio: proximo),
              ],
            ),
          ),
        );
      },
    );
  }
}
