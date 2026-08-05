// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_historial.dart
//
// Sección "Historial" de SolicitudDetalleView — línea de tiempo de eventos.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionHistorial extends StatelessWidget {
  final List<HistorialSolicitud> historial;

  const SeccionHistorial({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return SeccionCard(
        colorIcono: AppColors.warning,
        icono: AppIcons.time,
        titulo: 'Historial',
        children: const [
          FilaInfo(
            etiqueta: '',
            valor: 'Todavía no hay movimientos registrados.',
            mostrarDivisor: false,
          ),
        ],
      );
    }

    return SeccionCard(
      colorIcono: AppColors.warning,
      icono: AppIcons.time,
      titulo: 'Historial',
      children: [
        for (int i = 0; i < historial.length; i++)
          _EntradaHistorial(
            fecha: historial[i].fecha.formatDate(AppDateFormat.shortDate),
            hora: historial[i].fecha.formatDate(AppDateFormat.hourMinute),
            titulo: historial[i].titulo,
            descripcion: historial[i].descripcion,
            activo: i == 0,
            esUltimo: i == historial.length - 1,
          ),
      ],
    );
  }
}

class _EntradaHistorial extends StatelessWidget {
  final String fecha;
  final String hora;
  final String titulo;
  final String descripcion;
  final bool activo;
  final bool esUltimo;

  const _EntradaHistorial({
    required this.fecha,
    required this.hora,
    required this.titulo,
    required this.descripcion,
    required this.activo,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorDot = activo ? AppColors.warning : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna: punto + línea vertical
        SizedBox(
          width: 16,
          child: Column(
            children: [
              const SizedBox(height: 3),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorDot,
                  shape: BoxShape.circle,
                ),
              ),
              if (!esUltimo)
                Container(
                  width: 2,
                  height: 52,
                  margin: const EdgeInsets.only(top: 3),
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Contenido del evento
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fecha,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      hora,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  titulo,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  descripcion,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
