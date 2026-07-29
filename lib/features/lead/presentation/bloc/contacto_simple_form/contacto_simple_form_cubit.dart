// lib/features/lead/presentation/bloc/contacto_simple_form/contacto_simple_form_cubit.dart
//
// Carga y guarda el ContactoSimple de la pantalla EditContactoSimple — ancla
// en idNumero, el único dato que recibe la pantalla (ver EditContactoSimplePage).
// Mismo patrón que ContactoFormCubit (contacto_form/), pantalla completa.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoSimpleFormCubit extends Cubit<ContactoSimpleFormState> {
  final LeadRepository _repository;

  ContactoSimpleFormCubit(this._repository)
    : super(const ContactoSimpleFormInitial());

  Future<void> cargarPorIdNumero(int idNumero) async {
    emit(const ContactoSimpleFormLoading());
    try {
      final contacto = await _repository.getContactoSimplePorIdNumero(
        idNumero,
      );
      emit(ContactoSimpleFormSuccess(contacto));
    } on AppException catch (e) {
      emit(ContactoSimpleFormFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ContactoSimpleFormFailure('Ocurrió un error inesperado.'));
    }
  }

  Future<CrudResult> guardar(ContactoSimple contacto) =>
      _repository.guardarContactoSimple(contacto);
}
