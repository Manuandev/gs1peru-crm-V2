// lib/core/presentation/widgets/app_historial_item.dart
//
// Fila de una línea de tiempo (historial) — ícono en círculo + línea vertical
// a la izquierda, descripción + origen + fecha a la derecha. Único estilo de
// historial de la app (2026-09-11): lo usan el Detalle de cobro y el Detalle
// de Solicitud, que antes tenían dos diseños distintos.
//
// No recibe "título": las actividades del backend casi nunca lo traen
// (LA.NOMBRE vacío) y dejaba un renglón en blanco sobre la descripción.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class AppHistorialItem extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String descripcion;
  // Canal/origen de la actividad — se muestra a la derecha si viene.
  final String origen;
  // Fecha ya formateada por el caller (ej. "08/09/2026 • 10:57").
  final String fechaTexto;
  final bool esUltimo;

  const AppHistorialItem({
    super.key,
    required this.icono,
    required this.color,
    required this.descripcion,
    this.origen = '',
    required this.fechaTexto,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna izquierda: ícono + línea vertical ──────
          Column(
            children: [
              Container(
                width: AppSizing.avatarXs,
                height: AppSizing.avatarXs,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: AppColors.opacityAvatarBg),
                ),
                child: Icon(icono, size: AppSizing.iconSm, color: color),
              ),
              if (!esUltimo)
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
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          descripcion,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (origen.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          origen,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    fechaTexto,
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
}
