// lib\features\home\presentation\widgets\dashboard\card_totales_home.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CardTotalItem(
                icon: AppIconsSocial.etapaNuevo,
                iconColor: AppIconsSocial.colorEstado("00"),
                cantidad: state.totLeadsNuevos,
                titulo: 'Nuevo',
              ),
              _VerticalDivider(color: colorScheme.outlineVariant),
              _CardTotalItem(
                icon: AppIconsSocial.etapaEnDesarrollo,
                iconColor: AppIconsSocial.colorEstado("01"),
                cantidad: state.totLeadsDesarrollo,
                titulo: 'Desarrollo',
              ),
              _VerticalDivider(color: colorScheme.outlineVariant),
              _CardTotalItem(
                icon: AppIconsSocial.etapaPropuesta,
                iconColor: AppIconsSocial.colorEstado("02"),
                cantidad: state.totPropuestas,
                titulo: 'Propuesta',
              ),
              _VerticalDivider(color: colorScheme.outlineVariant),
              _CardTotalItem(
                icon: AppIcons.moneda,
                iconColor: ColorUtils.fromName('Cobranza'),
                cantidad: state.totCobranza,
                titulo: 'Cobranza',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTotalItem extends StatelessWidget {
  final dynamic icon;
  final Color iconColor;
  final int cantidad;
  final String titulo;

  const _CardTotalItem({
    required this.icon,
    required this.iconColor,
    required this.cantidad,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon is IconData
              ? Icon(icon as IconData, color: iconColor, size: AppSizing.iconLg)
              : FaIcon(
                  icon as FaIconData,
                  color: iconColor,
                  size: AppSizing.iconLg,
                ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            cantidad.toString(),
            style: themeText.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            titulo,
            style: themeText.labelSmall?.copyWith(
              color: iconColor.withAlpha(180),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
