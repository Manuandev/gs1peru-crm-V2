// lib/features/chat/presentation/widgets/chat_list/contadores_chat_row.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ContadoresChatRow extends StatelessWidget {
  final ContadoresChat contadores;

  const ContadoresChatRow({super.key, required this.contadores});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ContadorItem(
              icon: AppIcons.chat,
              iconColor: AppColors.error,
              cantidad: contadores.sinResponder,
              titulo: 'Sin responder',
            ),
            _Separador(color: colorScheme.outlineVariant),
            _ContadorItem(
              icon: AppIcons.sparkle,
              iconColor: AppColors.brandLavenderAccessible,
              cantidad: contadores.derivadasPorIA,
              titulo: 'Derivadas por IA',
            ),
            _Separador(color: colorScheme.outlineVariant),
            _ContadorItem(
              icon: AppIcons.fileWord,
              iconColor: AppColors.info,
              cantidad: contadores.conPropuesta,
              titulo: 'Con propuesta',
            ),
            _Separador(color: colorScheme.outlineVariant),
            _ContadorItem(
              icon: AppIcons.moneda,
              iconColor: AppColors.warning,
              cantidad: contadores.enCobranza,
              titulo: 'En cobranza',
            ),
          ],
        ),
      ),
    );
  }
}

class _ContadorItem extends StatelessWidget {
  final dynamic icon; // IconData o FaIconData
  final Color iconColor;
  final int cantidad;
  final String titulo;

  const _ContadorItem({
    required this.icon,
    required this.iconColor,
    required this.cantidad,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon is IconData
              ? Icon(icon as IconData, color: iconColor, size: AppSizing.iconMd)
              : FaIcon(
                  icon as FaIconData,
                  color: iconColor,
                  size: AppSizing.iconActionSm,
                ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$cantidad',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            titulo,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: AppTextStyles
                  .sizeXs, // 11px — garantiza que los labels más largos quepan en 2 líneas
              color: iconColor.withValues(alpha: AppColors.opacityIconMuted),
              fontWeight: AppTextStyles.weightSemiBold,
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

class _Separador extends StatelessWidget {
  final Color color;
  const _Separador({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: VerticalDivider(width: 1, thickness: 1, color: color),
    );
  }
}
