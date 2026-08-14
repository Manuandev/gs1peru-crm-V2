// lib/features/cobranza/presentation/widgets/lista/cobranza_summary_cards.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaSummaryCards extends StatelessWidget {
  final Map<int, int> conteosPorEstado;
  final Set<int> estadosSeleccionados;
  final void Function(int idEstado) onEstadoTap;

  const CobranzaSummaryCards({
    super.key,
    required this.conteosPorEstado,
    required this.estadosSeleccionados,
    required this.onEstadoTap,
  });

  // ID_ESTADO_GES crudo (DBO.[edu.TIP_ESTADO_GES]): 0=Pend.deDocumento
  // 2=Facturar 5=Pend.factura 3=Cancelado. El color de cada tarjeta sale de
  // colorEstadoGes (ver cobranza_estado_utils.dart) — mismo color que ya
  // pintan CobranzaCard/CobranzaDetalleInfoCard para ese idEstado.
  static const _tarjetas = [
    _TarjetaDef(idEstado: 0, label: 'Pend.\ndocumento', icon: AppIcons.fileOutlined),
    _TarjetaDef(idEstado: 2, label: 'Facturar', icon: AppIcons.receipt),
    _TarjetaDef(idEstado: 5, label: 'Pend. pago', icon: AppIcons.time),
    _TarjetaDef(idEstado: 3, label: 'Cancelado', icon: AppIcons.checkCircle),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
  final int idEstado;
  final String label;
  final IconData icon;

  const _TarjetaDef({
    required this.idEstado,
    required this.label,
    required this.icon,
  });

  Color get color => colorEstadoGes(idEstado);
}
