// lib/core/utils/cobranza_update_notifier.dart

import 'dart:async';

/// Payload que viaja por el notifier cada vez que se factura una cobranza.
class CobranzaUpdate {
  final String numSol;
  final int idEstado;
  const CobranzaUpdate(this.numSol, {required this.idEstado});
}

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
