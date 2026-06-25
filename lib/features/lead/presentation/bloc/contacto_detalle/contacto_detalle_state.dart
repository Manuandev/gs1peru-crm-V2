// lib/features/lead/presentation/bloc/contacto_detalle/contacto_detalle_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

sealed class ContactoDetalleState extends Equatable {
  const ContactoDetalleState();

  @override
  List<Object?> get props => [];
}

final class ContactoDetalleInitial extends ContactoDetalleState {
  const ContactoDetalleInitial();
}

final class ContactoDetalleCargando extends ContactoDetalleState {
  const ContactoDetalleCargando();
}

final class ContactoDetalleCargado extends ContactoDetalleState {
  final ContactoDetalle contacto;
  final List<NegociacionLead> negociaciones;

  const ContactoDetalleCargado({
    required this.contacto,
    required this.negociaciones,
  });

  @override
  List<Object?> get props => [contacto, negociaciones];
}

final class ContactoDetalleError extends ContactoDetalleState {
  final String mensaje;

  const ContactoDetalleError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
