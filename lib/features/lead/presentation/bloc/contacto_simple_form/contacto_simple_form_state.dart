// lib/features/lead/presentation/bloc/contacto_simple_form/contacto_simple_form_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class ContactoSimpleFormState extends Equatable {
  const ContactoSimpleFormState();

  @override
  List<Object?> get props => [];
}

class ContactoSimpleFormInitial extends ContactoSimpleFormState {
  const ContactoSimpleFormInitial();
}

class ContactoSimpleFormLoading extends ContactoSimpleFormState {
  const ContactoSimpleFormLoading();
}

class ContactoSimpleFormSuccess extends ContactoSimpleFormState {
  final ContactoSimple contacto;
  const ContactoSimpleFormSuccess(this.contacto);

  @override
  List<Object?> get props => [contacto];
}

class ContactoSimpleFormFailure extends ContactoSimpleFormState {
  final String message;
  const ContactoSimpleFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
