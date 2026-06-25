// lib/core/utils/lead_update_notifier.dart

import 'dart:async';

/// Payload que viaja por el notifier cada vez que se edita un lead.
///
/// [updatedLead] es `Object?` para evitar dependencia core → features/lead.
/// Los suscriptores en features/lead y features/chat castean a `Lead`.
class LeadUpdate {
  final int idLead;
  final Object? updatedLead;
  const LeadUpdate(this.idLead, {this.updatedLead});
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

  void notify(int idLead, {Object? updatedLead}) {
    if (!_controller.isClosed) {
      _controller.add(LeadUpdate(idLead, updatedLead: updatedLead));
    }
  }
}
