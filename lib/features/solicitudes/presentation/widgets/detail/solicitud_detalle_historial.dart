// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_historial.dart
//
// Sección "Historial" de SolicitudDetalleView — AppHistorialSeccion (core),
// el mismo historial (seguimiento + comentario + recordatorio) y el mismo
// ítem que Conversaciones, Seguimiento y el Detalle de cobro. Solo de la
// negociación de esta solicitud (SP 'DV', sección [3]).

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class SeccionHistorial extends StatelessWidget {
  final List<HistorialComentario> historial;

  const SeccionHistorial({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    return AppHistorialSeccion(
      eventos: historial,
      mensajeVacio: 'Esta solicitud aún no registra movimientos.',
    );
  }
}
