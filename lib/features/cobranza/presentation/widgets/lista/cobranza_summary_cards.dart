// lib/features/cobranza/presentation/widgets/lista/cobranza_summary_cards.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class CobranzaSummaryCards extends StatelessWidget {
  final Map<String, int> conteosPorEstado;
  final Set<String> estadosSeleccionados;
  final void Function(String idEstado) onEstadoTap;

  const CobranzaSummaryCards({
    super.key,
    required this.conteosPorEstado,
    required this.estadosSeleccionados,
    required this.onEstadoTap,
  });

  static const _tarjetas = [
    _TarjetaDef(
      idEstado: 'PD',
      label: 'Pend.\ndocumento',
      icon: AppIcons.fileOutlined,
      color: AppColors.warning,
    ),
    _TarjetaDef(
      idEstado: 'F',
      label: 'Facturar',
      icon: AppIcons.receipt,
      color: AppColors.primary,
    ),
    _TarjetaDef(
      idEstado: 'PP',
      label: 'Pend. pago',
      icon: AppIcons.time,
      color: AppColors.secondary,
    ),
    _TarjetaDef(
      idEstado: 'CA',
      label: 'Cancelado',
      icon: AppIcons.checkCircle,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _tarjetas.map((t) {
          final isActiva = estadosSeleccionados.isEmpty ||
              estadosSeleccionados.contains(t.idEstado);
          final count = conteosPorEstado[t.idEstado] ?? 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _SummaryCard(
                def: t,
                count: count,
                isActiva: isActiva,
                onTap: () => onEstadoTap(t.idEstado),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _TarjetaDef def;
  final int count;
  final bool isActiva;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.def,
    required this.count,
    required this.isActiva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActiva
              ? def.color.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: isActiva
                ? def.color
                : AppColors.border,
            width: isActiva ? AppSizing.borderWidthThin * 2 : AppSizing.borderWidthThin,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppSizing.shadowBlurSm,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              def.icon,
              size: AppSizing.iconMd,
              color: isActiva ? def.color : AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$count',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: AppTextStyles.weightBold,
                color: isActiva ? def.color : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              def.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActiva ? AppColors.textSecondary : AppColors.textDisabled,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaDef {
  final String idEstado;
  final String label;
  final IconData icon;
  final Color color;

  const _TarjetaDef({
    required this.idEstado,
    required this.label,
    required this.icon,
    required this.color,
  });
}
