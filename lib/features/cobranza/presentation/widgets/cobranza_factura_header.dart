// lib/features/cobranza/presentation/widgets/cobranza_factura_header.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaHeader extends StatelessWidget {
  final CobranzaFacturaState state;
  const CobranzaFacturaHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: state.esCredito
          ? _LayoutCredito(state: state)
          : _LayoutContado(state: state),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Crédito: avatar+nombre+curso arriba, monto+chip debajo centrado
// ─────────────────────────────────────────────────────────────────────────────

class _LayoutCredito extends StatelessWidget {
  final CobranzaFacturaState state;
  const _LayoutCredito({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(nombre: state.nombre),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.nombre.toUpperCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    state.oportunidad,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monto total',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'S/ ${state.montoTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                ),
              ],
            ),
            _ChipCondicion(idCondicion: state.idCondicion, condicion: state.condicion),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Contado: avatar+nombre+curso a la izquierda, monto+chip a la derecha
// ─────────────────────────────────────────────────────────────────────────────

class _LayoutContado extends StatelessWidget {
  final CobranzaFacturaState state;
  const _LayoutContado({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(nombre: state.nombre),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.nombre.toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                state.oportunidad,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            _ChipCondicion(
              idCondicion: state.idCondicion,
              condicion: state.condicion,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip de condición de pago
// ─────────────────────────────────────────────────────────────────────────────

class _ChipCondicion extends StatelessWidget {
  final String idCondicion;
  final String condicion;
  const _ChipCondicion({required this.idCondicion, required this.condicion});

  @override
  Widget build(BuildContext context) {
    final esCredito = idCondicion == 'CR';
    final color = esCredito ? AppColors.primary : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        condicion,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar compartido
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String nombre;
  const _Avatar({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppSizing.avatarRadiusMd,
      backgroundColor: AvatarUtils.color(nombre),
      child: Text(
        AvatarUtils.initials(nombre),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnDark,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
