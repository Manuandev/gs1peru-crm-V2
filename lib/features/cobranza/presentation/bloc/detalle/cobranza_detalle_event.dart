// lib/features/cobranza/presentation/bloc/detalle/cobranza_detalle_event.dart

abstract class CobranzaDetalleEvent {
  const CobranzaDetalleEvent();
}

class CobranzaDetalleStarted extends CobranzaDetalleEvent {
  final String idCobranza;
  const CobranzaDetalleStarted(this.idCobranza);
}
