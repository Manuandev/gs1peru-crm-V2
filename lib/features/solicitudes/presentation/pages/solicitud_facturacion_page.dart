// lib/features/solicitudes/presentation/pages/solicitud_facturacion_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudFacturacionPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudFacturacionPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return SolicitudFacturacionView(
      solicitud: solicitud,
      modoEdicion: modoEdicion,
    );
  }
}
