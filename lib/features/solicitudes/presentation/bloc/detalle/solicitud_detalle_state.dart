// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_state.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
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
  // Cabecera recién traída en la misma llamada 'DV' (sección [2]) —
  // reemplaza a la que llega por navegación (que puede venir de una lista
  // cacheada hace rato, o incluso de un Solicitud "de paso" casi vacío armado
  // desde una Negociacion). Null solo si el SP desplegado todavía no trae esa
  // sección — ahí la vista cae de vuelta al Solicitud de navegación.
  final Solicitud? solicitud;
  const SolicitudDetalleSuccess(this.detalle, this.solicitud);
}

class SolicitudDetalleError extends SolicitudDetalleState {
  final String mensaje;
  const SolicitudDetalleError(this.mensaje);
}
