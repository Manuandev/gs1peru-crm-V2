// lib/features/solicitudes/presentation/pages/solicitud_resumen_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudResumenPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudResumenPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return SolicitudResumenView(
      solicitud: solicitud,
      modoEdicion: modoEdicion,
    );
  }
}
