// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_historial.dart
//
// Sección "Historial" del detalle de cobro — AppHistorialSeccion (core), el
// mismo historial (seguimiento + comentario + recordatorio) y el mismo ítem
// que Conversaciones, Seguimiento y el Detalle de Solicitud. Solo de la
// negociación de esta solicitud (SP 'DT', sección [3]).

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class CobranzaDetalleHistorial extends StatelessWidget {
  final List<HistorialComentario> historial;
  const CobranzaDetalleHistorial({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    return AppHistorialSeccion(
      eventos: historial,
      mensajeVacio: 'Esta solicitud aún no registra movimientos.',
    );
  }
}
