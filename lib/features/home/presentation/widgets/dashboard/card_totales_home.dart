// lib/features/home/presentation/widgets/dashboard/card_totales_home.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class CardTotalesHome extends StatelessWidget {
  final HomeLoaded state;

  const CardTotalesHome({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CatalogsBloc, CatalogsState>(
      builder: (context, catalogState) {
        if (catalogState is! CatalogsLoaded) return const SizedBox.shrink();

        return _buildCard(context, colorScheme, catalogState);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    ColorScheme colorScheme,
    CatalogsLoaded catalogState,
  ) {
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
                  // Igual que los 4 totales de abajo: el embudo cuenta sin
                  // rango de fechas, así que Seguimiento tiene que abrir con
                  // los checkbox de Desde/Hasta apagados — si no, la lista
                  // sale recortada al mes actual y no cuadra con el número
                  // que el usuario acaba de tocar.
                  onTap: () => context.goToSeguimiento(sinRangoFecha: true),
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
                    iconColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoNuevo),
                    cantidad: state.totLeadsNuevos,
                    titulo: 'Nuevos',
                    onTap: () => context.goToSeguimiento(
                      filtroInicial: LeadListFiltro.nuevos,
                      sinRangoFecha: true,
                    ),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.accessTime,
                    iconColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoEnDesarrollo),
                    cantidad: state.totLeadsDesarrollo,
                    titulo: 'En desarrollo',
                    onTap: () => context.goToSeguimiento(
                      filtroInicial: LeadListFiltro.enDesarrollo,
                      sinRangoFecha: true,
                    ),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.datosLead,
                    iconColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoConPropuesta),
                    cantidad: state.totPropuestas,
                    titulo: 'Propuestas',
                    onTap: () => context.goToSeguimiento(
                      filtroInicial: LeadListFiltro.propuesta,
                      sinRangoFecha: true,
                    ),
                  ),
                  _VerticalDivider(color: colorScheme.outlineVariant),
                  _CardTotalItem(
                    icon: AppIcons.moneda,
                    iconColor: AppSocialUtils.colorEstado(catalogState.valoresDefecto.idEstadoGanado),
                    cantidad: state.totCobranza,
                    titulo: 'Cobranza',
                    onTap: () => context.goToCobranza(sinRangoFecha: true),
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
