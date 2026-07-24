// lib/features/lead/presentation/bloc/contacto_form/contacto_form_cubit.dart
//
// Carga y guarda el ContactoDetalle de la pantalla EditContacto — ancla en
// idNumero, el único dato que recibe la pantalla (ver EditContactoPage).
// ⚠️ LeadRepository.getContactoPorIdNumero/guardarContacto todavía golpean
// un endpoint provisional — ver lead_remote_datasource.dart y lead/CLAUDE.md.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoFormCubit extends Cubit<ContactoFormState> {
  final LeadRepository _repository;

  ContactoFormCubit(this._repository) : super(const ContactoFormInitial());

  Future<void> cargarPorIdNumero(int idNumero) async {
    emit(const ContactoFormLoading());
    try {
      final contacto = await _repository.getContactoPorIdNumero(idNumero);
      emit(ContactoFormSuccess(contacto));
    } on AppException catch (e) {
      emit(ContactoFormFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ContactoFormFailure('Ocurrió un error inesperado.'));
    }
  }

  Future<CrudResult> guardar(ContactoDetalle contacto) =>
      _repository.guardarContacto(contacto);
}
