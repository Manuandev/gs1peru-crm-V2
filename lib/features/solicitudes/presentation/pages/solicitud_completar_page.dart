// lib/features/solicitudes/presentation/pages/solicitud_completar_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCompletarPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudCompletarPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return SolicitudCompletarView(
      solicitud: solicitud,
      modoEdicion: modoEdicion,
    );
  }
}
