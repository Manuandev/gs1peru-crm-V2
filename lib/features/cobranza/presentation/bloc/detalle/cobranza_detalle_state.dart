// lib/features/cobranza/presentation/bloc/detalle/cobranza_detalle_state.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaDetalleState {
  const CobranzaDetalleState();
}

class CobranzaDetalleInitial extends CobranzaDetalleState {
  const CobranzaDetalleInitial();
}

class CobranzaDetalleLoading extends CobranzaDetalleState {
  const CobranzaDetalleLoading();
}

class CobranzaDetalleSuccess extends CobranzaDetalleState {
  final CobranzaDetalle detalle;
  const CobranzaDetalleSuccess(this.detalle);
}

class CobranzaDetalleError extends CobranzaDetalleState {
  final String mensaje;
  const CobranzaDetalleError(this.mensaje);
}
