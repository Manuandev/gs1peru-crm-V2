// lib/features/cobranza/presentation/bloc/cobranza_detalle_event.dart

abstract class CobranzaDetalleEvent {
  const CobranzaDetalleEvent();
}

class CobranzaDetalleStarted extends CobranzaDetalleEvent {
  final int idCobranza;
  const CobranzaDetalleStarted(this.idCobranza);
}
