// lib/core/utils/contacto_update_notifier.dart
//
// Mismo patrón que LeadUpdateNotifier — bus de comunicación entre
// EditContactoPortrait y cualquier pantalla que ya tenga cacheado un Chat/
// Negociacion con datos de contacto (nombre, apellido, empresa...) que
// necesite refrescarse al volver de editar. Emite un ContactoUpdate cada vez
// que un contacto se guarda exitosamente, keyed por idNumero (el ancla de
// EditContactoPage).

import 'dart:async';

class ContactoUpdate {
  final int idNumero;
  const ContactoUpdate(this.idNumero);
}

class ContactoUpdateNotifier {
  ContactoUpdateNotifier._();
  static final instance = ContactoUpdateNotifier._();

  final _controller = StreamController<ContactoUpdate>.broadcast();
  Stream<ContactoUpdate> get stream => _controller.stream;

  void notify(int idNumero) {
    if (!_controller.isClosed) {
      _controller.add(ContactoUpdate(idNumero));
    }
  }
}
