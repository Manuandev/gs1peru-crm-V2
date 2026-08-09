// lib/features/lead/presentation/widgets/contacto_detalle/lead_recordatorio_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Card de un recordatorio — reusada por `ProximoRecordatorioCard`
/// (Información) y `RecordatoriosTab` (lista completa). Muestra el nombre
/// real de quien lo creó (resuelto vía `CatalogsBloc.asesores` a partir del
/// CODUSER crudo, `LeadRecordatorio.idUsuarioC`) — nunca un badge de rol
/// (a diferencia de HistorialComentario/_HistorialItem).
class LeadRecordatorioCard extends StatelessWidget {
  final LeadRecordatorio recordatorio;

  const LeadRecordatorioCard({super.key, required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: LeadRecordatorioContent(recordatorio: recordatorio),
    );
  }
}

/// Contenido de un recordatorio sin decoración de card — ícono + título +
/// fecha + nombre de quien lo creó. Usado dentro de `LeadRecordatorioCard`
/// y directo en `ProximoRecordatorioCard` (que arma su propia card con un
/// encabezado "PRÓXIMO RECORDATORIO" + botón "Ver todos" arriba).
class LeadRecordatorioContent extends StatelessWidget {
  final LeadRecordatorio recordatorio;

  const LeadRecordatorioContent({super.key, required this.recordatorio});

  static String _resolverNombreUsuario(BuildContext context, String codUser) {
    if (codUser.isEmpty) return '';
    final state = context.watch<CatalogsBloc>().state;
    if (state is! CatalogsLoaded) return codUser;
    return state.asesores
            .where((a) => a.codUser == codUser)
            .firstOrNull
            ?.nombre ??
        codUser;
  }

  @override
  Widget build(BuildContext context) {
    final titulo = recordatorio.comentario.isNotEmpty
        ? recordatorio.comentario
        : recordatorio.accionDescripcion;
    final nombreUsuario = _resolverNombreUsuario(
      context,
      recordatorio.idUsuarioC,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizing.actorCircleSize,
          height: AppSizing.actorCircleSize,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            AppIcons.recordatorio,
            size: AppSizing.iconSm,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo.isEmpty ? '—' : titulo,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              if (recordatorio.comentario.isNotEmpty &&
                  recordatorio.accionDescripcion.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  recordatorio.accionDescripcion,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    AppIcons.time,
                    size: AppSizing.iconXs,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    recordatorio.fechaRecordatorio.formatConDia(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (nombreUsuario.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    const Icon(
                      AppIcons.user,
                      size: AppSizing.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      nombreUsuario,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
