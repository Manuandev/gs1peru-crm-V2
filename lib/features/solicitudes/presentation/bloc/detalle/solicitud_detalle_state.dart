// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_state.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud_detalle.dart';

abstract class SolicitudDetalleState {
  const SolicitudDetalleState();
}

class SolicitudDetalleInitial extends SolicitudDetalleState {
  const SolicitudDetalleInitial();
}

class SolicitudDetalleLoading extends SolicitudDetalleState {
  const SolicitudDetalleLoading();
}

class SolicitudDetalleSuccess extends SolicitudDetalleState {
  final SolicitudDetalle detalle;
  const SolicitudDetalleSuccess(this.detalle);
}

class SolicitudDetalleError extends SolicitudDetalleState {
  final String mensaje;
  const SolicitudDetalleError(this.mensaje);
}
