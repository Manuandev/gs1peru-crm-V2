// lib/features/cobranza/presentation/bloc/detalle/cobranza_detalle_event.dart

abstract class CobranzaDetalleEvent {
  const CobranzaDetalleEvent();
}

class CobranzaDetalleStarted extends CobranzaDetalleEvent {
  final String idCobranza;
  const CobranzaDetalleStarted(this.idCobranza);
}

// Llega desde CobranzaUpdateNotifier tras facturar — parchea idEstado/estado
// y condición de pago en memoria, sin volver a pedir el detalle al backend.
class CobranzaDetalleItemActualizado extends CobranzaDetalleEvent {
  final int idEstado;
  final String idCondicion;
  final String condicion;
  const CobranzaDetalleItemActualizado(
    this.idEstado,
    this.idCondicion,
    this.condicion,
  );
}
