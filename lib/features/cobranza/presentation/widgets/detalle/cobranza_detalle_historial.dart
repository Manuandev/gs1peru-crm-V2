// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_historial.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleHistorial extends StatelessWidget {
  final List<HistorialCobranza> historial;
  const CobranzaDetalleHistorial({super.key, required this.historial});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(historial.length, (i) {
            final entrada = historial[i];
            final esUltima = i == historial.length - 1;
            return _EntradaHistorial(
              entrada: entrada,
              esUltima: esUltima,
            );
          }),
        ],
      ),
    );
  }
}

class _EntradaHistorial extends StatelessWidget {
  final HistorialCobranza entrada;
  final bool esUltima;

  const _EntradaHistorial({required this.entrada, required this.esUltima});

  @override
  Widget build(BuildContext context) {
    final color = _colorTipo(entrada.idTipo);
    final icono = _iconoTipo(entrada.idTipo);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna izquierda: ícono + línea vertical ──────
          Column(
            children: [
              Container(
                width: AppSizing.avatarSm,
                height: AppSizing.avatarSm,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(icono, size: AppSizing.iconSm, color: color),
              ),
              if (!esUltima)
                Expanded(
                  child: Container(
                    width: AppSizing.borderWidthThin * 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Columna derecha: contenido ─────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltima ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entrada.titulo,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: AppTextStyles.weightSemiBold,
                          ),
                        ),
                      ),
                      Text(
                        entrada.ejecutivo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    entrada.descripcion,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${entrada.fecha} • ${entrada.hora}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorTipo(String idTipo) {
    switch (idTipo) {
      case 'estado':
        return AppColors.warning;
      case 'pago':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconoTipo(String idTipo) {
    switch (idTipo) {
      case 'estado':
        return AppIcons.fileOutlined;
      case 'recordatorio':
        return AppIcons.email;
      case 'pago':
        return AppIcons.moneda;
      default:
        return AppIcons.fileGeneric;
    }
  }
}
