// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_historial.dart
//
// Sección "Historial" de SolicitudDetalleView — AppSeccionCard +
// AppHistorialItem (core), mismo estilo que el Historial del Detalle de cobro.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionHistorial extends StatelessWidget {
  final List<HistorialSolicitud> historial;

  const SeccionHistorial({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    return AppSeccionCard(
      colorIcono: AppColors.warning,
      icono: AppIcons.time,
      titulo: 'Historial',
      children: [
        if (historial.isEmpty)
          const AppSeccionVacia(
            icono: AppIcons.historial,
            color: AppColors.warning,
            titulo: 'Sin movimientos registrados',
            mensaje:
                'Aquí se registrarán las validaciones, cambios de estado y '
                'gestiones que se realicen sobre esta solicitud.',
          )
        else
          for (int i = 0; i < historial.length; i++)
            AppHistorialItem(
              icono: AppIcons.fileGeneric,
              color: AppColors.primary,
              descripcion: historial[i].descripcion,
              origen: historial[i].origen,
              fechaTexto:
                  '${historial[i].fecha.formatDate(AppDateFormat.shortDate)}'
                  ' • '
                  '${historial[i].fecha.formatDate(AppDateFormat.hourMinute)}',
              esUltimo: i == historial.length - 1,
            ),
      ],
    );
  }
}
