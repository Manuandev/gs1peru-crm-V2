// lib/features/solicitudes/presentation/pages/solicitud_generada_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudGeneradaPage extends StatelessWidget {
  final Solicitud solicitud;

  const SolicitudGeneradaPage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return SolicitudGeneradaView(solicitud: solicitud);
  }
}
