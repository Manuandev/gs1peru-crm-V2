// lib/features/cobranza/presentation/widgets/cobranza_factura_header.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Header fijo — no cambia cuando el usuario cambia la condición de pago.
/// Solo el chip de condición actualiza su color (primary/success).
class CobranzaFacturaHeader extends StatelessWidget {
  final CobranzaFacturaState state;
  const CobranzaFacturaHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final esCredito = state.idCondicion == 'CR';
    final chipColor = esCredito ? AppColors.primary : AppColors.success;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ────────────────────────────────────────────
          CircleAvatar(
            radius: AppSizing.avatarRadiusMd,
            backgroundColor: AvatarUtils.color(state.nombre),
            child: Text(
              AvatarUtils.initials(state.nombre),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Nombre + curso ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.nombre.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  state.oportunidad,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Monto + chip ──────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Monto total',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'S/ ${state.montoTotal.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              // Chip animado: solo el color cambia
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                  border: Border.all(
                    color: chipColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  state.condicion,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: chipColor,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
