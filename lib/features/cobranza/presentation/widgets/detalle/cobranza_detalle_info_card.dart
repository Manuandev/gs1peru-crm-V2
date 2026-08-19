// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_info_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleInfoCard extends StatelessWidget {
  final CobranzaDetalle detalle;
  const CobranzaDetalleInfoCard({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna izquierda: avatar + datos ──────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: AppSizing.avatarRadiusSm,
                      backgroundColor:
                          AvatarUtils.color(detalle.nombreCompleto),
                      child: Text(
                        AvatarUtils.initials(detalle.nombreCompleto),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        detalle.nombreCompleto.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoFila(
                  icono: AppIcons.interes,
                  label: 'Oportunidad',
                  valor: detalle.oportunidad,
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoFila(
                  icono: AppIcons.user,
                  label: 'Ejecutivo',
                  valor: detalle.ejecutivo,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Columna derecha: monto + estado + condición + fecha ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Monto total',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${resolverSimboloMoneda(context, detalle.monedaId)}${NumberFormatUtils.formatMonto(detalle.montoTotal)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _EstadoBadge(idEstado: detalle.idEstado, estado: detalle.estado),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Condición de pago',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                detalle.condicion,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fecha de solicitud',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.calendar,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    // fechaSolicitud viene crudo del backend (DATETIME sin
                    // CONVERT) — mismo formato compacto que en CobranzaCard
                    // ("Hoy 10:22"/"Ayer 10:22"/"miércoles 10:22"/"26/03/2025"),
                    // en vez del texto largo anterior.
                    detalle.fechaSolicitud.formatConDia(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _InfoFila({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: AppSizing.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                valor,
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final int idEstado;
  final String estado;
  const _EstadoBadge({required this.idEstado, required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = colorEstadoGes(idEstado);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
      ),
      child: Text(
        estado,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
