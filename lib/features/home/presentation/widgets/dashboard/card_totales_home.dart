// lib/features/home/presentation/widgets/dashboard/card_totales_home.dart

import 'package:app_crm/config/index_config.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class CardTotalesHome extends StatelessWidget {
  final HomeLoaded state;

  const CardTotalesHome({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Encabezado ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mi embudo de gestión',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goToSeguimiento(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver detalle',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colorScheme.primary,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                      Icon(
                        AppIcons.chevronRight,
                        size: AppSizing.iconSm,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Los 4 totales ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.sm,
              top: AppSpacing.xxs,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CardTotalItem(
                    icon: AppIcons.leadNuevo,
                    iconColor: AppSocialUtils.colorEstado('00'),
                    cantidad: state.totLeadsNuevos,
                    titulo: 'Nuevos',
                    onTap: () => context.goToSeguimiento(),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.accessTime,
                    iconColor: AppSocialUtils.colorEstado('01'),
                    cantidad: state.totLeadsDesarrollo,
                    titulo: 'En gestión',
                    onTap: () => context.goToSeguimiento(),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.datosLead,
                    iconColor: AppSocialUtils.colorEstado('02'),
                    cantidad: state.totPropuestas,
                    titulo: 'Propuestas',
                    onTap: () => context.goToSeguimiento(),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.moneda,
                    iconColor: AppSocialUtils.colorEstado('04'),
                    cantidad: state.totCobranza,
                    titulo: 'Cobranza',
                    onTap: () => context.goToCobranza(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTotalItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int cantidad;
  final String titulo;
  final VoidCallback onTap;

  const _CardTotalItem({
    required this.icon,
    required this.iconColor,
    required this.cantidad,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorMuted = iconColor.withValues(alpha: AppColors.opacityIconMuted);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: AppSizing.iconLg),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              titulo,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorMuted,
                fontWeight: AppTextStyles.weightSemiBold,
                letterSpacing: AppTextStyles.letterSpacingNarrow,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              cantidad.toString(),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: AppTextStyles.weightBold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Icon(
              AppIcons.chevronRight,
              size: AppSizing.iconXxs,
              color: colorMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: VerticalDivider(width: 1, thickness: 1, color: color),
    );
  }
}
