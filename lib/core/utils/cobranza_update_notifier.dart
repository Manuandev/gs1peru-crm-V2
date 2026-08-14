// lib/core/utils/cobranza_update_notifier.dart

import 'dart:async';

/// Payload que viaja por el notifier cada vez que se factura una cobranza.
class CobranzaUpdate {
  final String numSol;
  final int idEstado;
  const CobranzaUpdate(this.numSol, {required this.idEstado});
}

/// Label corto por `ID_ESTADO_GES` — mismo texto que ya usan las tarjetas de
/// la lista (`CobranzaSummaryCards`) y el stepper del detalle
/// (`CobranzaDetalleStepper`). Los suscriptores del notifier lo usan para
/// parchear `Cobranza.estado`/`CobranzaDetalle.estado` en memoria junto con
/// `idEstado` — sin esto, el color del badge avanza (deriva de `idEstado`)
/// pero el texto se queda con la descripción vieja que trajo el backend.
/// Vacío = estado no reconocido, el caller debe conservar el texto anterior.
String cobranzaEstadoLabel(int idEstado) => switch (idEstado) {
  0 => 'Pend. de Documento',
  2 => 'Facturar',
  5 => 'Pend. de Pago',
  3 => 'Cancelado',
  _ => '',
};

/// Bus de comunicación entre [CobranzaFacturaBloc] y los BLoCs de
/// lista/detalle de cobranza — mismo patrón que [LeadUpdateNotifier].
///
/// Emite un [CobranzaUpdate] cada vez que se factura una cobranza con éxito.
/// [CobranzaListBloc] parchea el ítem en memoria (badge/tarjetas se
/// recalculan solos); [CobranzaDetalleBloc] recarga el detalle si es el
/// mismo `numSol` que tiene abierto.
class CobranzaUpdateNotifier {
  CobranzaUpdateNotifier._();
  static final instance = CobranzaUpdateNotifier._();

  final _controller = StreamController<CobranzaUpdate>.broadcast();
  Stream<CobranzaUpdate> get stream => _controller.stream;

  void notify(String numSol, {required int idEstado}) {
    if (!_controller.isClosed) {
      _controller.add(CobranzaUpdate(numSol, idEstado: idEstado));
    }
  }
}
