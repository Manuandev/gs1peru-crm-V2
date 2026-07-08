// lib/core/utils/lead_update_notifier.dart

import 'dart:async';

/// Payload que viaja por el notifier cada vez que se edita un lead.
///
/// [updatedLead] es `Object?` para evitar dependencia core → features/lead.
/// Los suscriptores en features/lead y features/chat castean a `Lead`.
class LeadUpdate {
  final int idLead;
  final Object? updatedLead;
  /// Quién disparó el guardado (normalmente el propio InfoLeadCubit que
  /// llamó a updateLead/updateEstado). Permite que ESE cubit ignore su
  /// propio aviso — ya tiene el estado fresco, no necesita recargarse a sí
  /// mismo — mientras otros suscriptores (LeadListBloc, otro InfoLeadCubit
  /// para el mismo lead en otra pantalla) sí reaccionan normalmente.
  final Object? source;
  const LeadUpdate(this.idLead, {this.updatedLead, this.source});
}

/// Bus de comunicación entre [EditLeadPortrait] y los BLoCs de lista.
///
/// Emite un [LeadUpdate] cada vez que un lead se guarda exitosamente.
/// [LeadListBloc] y [ChatListBloc] suscriben para parchear en memoria.
/// [InfoLeadCubit] suscribe para recargar cuando corresponde.
class LeadUpdateNotifier {
  LeadUpdateNotifier._();
  static final instance = LeadUpdateNotifier._();

  final _controller = StreamController<LeadUpdate>.broadcast();
  Stream<LeadUpdate> get stream => _controller.stream;

  void notify(int idLead, {Object? updatedLead, Object? source}) {
    if (!_controller.isClosed) {
      _controller.add(
        LeadUpdate(idLead, updatedLead: updatedLead, source: source),
      );
    }
  }
}
