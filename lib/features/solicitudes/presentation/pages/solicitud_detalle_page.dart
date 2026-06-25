// lib/features/solicitudes/presentation/pages/solicitud_detalle_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetallePage extends StatelessWidget {
  final Solicitud solicitud;

  const SolicitudDetallePage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return SolicitudDetalleView(solicitud: solicitud);
  }
}
