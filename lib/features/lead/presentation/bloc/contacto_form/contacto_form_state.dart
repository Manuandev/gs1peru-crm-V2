// lib/features/lead/presentation/bloc/contacto_form/contacto_form_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class ContactoFormState extends Equatable {
  const ContactoFormState();

  @override
  List<Object?> get props => [];
}

class ContactoFormInitial extends ContactoFormState {
  const ContactoFormInitial();
}

class ContactoFormLoading extends ContactoFormState {
  const ContactoFormLoading();
}

class ContactoFormSuccess extends ContactoFormState {
  final ContactoDetalle contacto;
  const ContactoFormSuccess(this.contacto);

  @override
  List<Object?> get props => [contacto];
}

class ContactoFormFailure extends ContactoFormState {
  final String message;
  const ContactoFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
