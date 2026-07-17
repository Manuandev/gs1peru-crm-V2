// lib/features/solicitudes/presentation/pages/solicitud_generada_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudGeneradaPage extends StatelessWidget {
  final Solicitud solicitud;
  final String comprobante;

  const SolicitudGeneradaPage({
    super.key,
    required this.solicitud,
    this.comprobante = '',
  });

  @override
  Widget build(BuildContext context) {
    return SolicitudGeneradaView(
      solicitud: solicitud,
      comprobante: comprobante,
    );
  }
}
