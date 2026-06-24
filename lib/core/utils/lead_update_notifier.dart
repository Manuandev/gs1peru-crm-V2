// lib/core/utils/lead_update_notifier.dart

import 'dart:async';

/// Emite el [idLead] de cualquier lead que acaba de ser editado.
/// Cualquier [InfoLeadCubit] que esté mostrando ese lead recibe la señal
/// y recarga automáticamente sus datos.
class LeadUpdateNotifier {
  LeadUpdateNotifier._();
  static final instance = LeadUpdateNotifier._();

  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;

  void notify(int idLead) {
    if (!_controller.isClosed) _controller.add(idLead);
  }
}
