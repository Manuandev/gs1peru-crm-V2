// lib/features/solicitudes/presentation/pages/solicitud_detalle_page.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetallePage extends StatelessWidget {
  final Solicitud solicitud;
  final bool origenValidar;

  const SolicitudDetallePage({
    super.key,
    required this.solicitud,
    this.origenValidar = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SolicitudDetalleBloc(
        GetDetalleSolicitudUseCase(context.read<SolicitudRepository>()),
        GetSolicitudesUseCase(context.read<SolicitudRepository>()),
      )..add(SolicitudDetalleStarted(solicitud.idSolicitud)),
      child: SolicitudDetalleView(
        solicitud: solicitud,
        origenValidar: origenValidar,
      ),
    );
  }
}
