// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_historial.dart
//
// Sección "Historial" del detalle de cobro — AppSeccionCard + AppHistorialItem
// (core), mismo estilo que el Historial del Detalle de Solicitud.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleHistorial extends StatelessWidget {
  final List<HistorialCobranza> historial;
  const CobranzaDetalleHistorial({super.key, required this.historial});

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
            mensaje: 'Aquí se registrarán los cambios de estado, la '
                'facturación y las gestiones de cobro de esta solicitud.',
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
