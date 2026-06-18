// lib/features/lead/presentation/bloc/contacto_detalle/contacto_detalle_event.dart

import 'package:app_crm/index_dependencies.dart';

sealed class ContactoDetalleEvent extends Equatable {
  const ContactoDetalleEvent();
}

final class ContactoDetalleStarted extends ContactoDetalleEvent {
  final int idContacto;
  const ContactoDetalleStarted(this.idContacto);

  @override
  List<Object?> get props => [idContacto];
}
