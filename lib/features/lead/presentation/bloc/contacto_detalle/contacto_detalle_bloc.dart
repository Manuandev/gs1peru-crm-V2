// lib/features/lead/presentation/bloc/contacto_detalle/contacto_detalle_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleBloc
    extends Bloc<ContactoDetalleEvent, ContactoDetalleState> {
  final ObtenerDetalleContactoUseCase _obtenerDetalle;
  final ObtenerNegociacionesContactoUseCase _obtenerNegociaciones;

  ContactoDetalleBloc({
    required ObtenerDetalleContactoUseCase obtenerDetalle,
    required ObtenerNegociacionesContactoUseCase obtenerNegociaciones,
  })  : _obtenerDetalle = obtenerDetalle,
        _obtenerNegociaciones = obtenerNegociaciones,
        super(const ContactoDetalleInitial()) {
    on<ContactoDetalleStarted>(_onStarted);
  }

  Future<void> _onStarted(
    ContactoDetalleStarted event,
    Emitter<ContactoDetalleState> emit,
  ) async {
    emit(const ContactoDetalleCargando());
    try {
      final contacto = await _obtenerDetalle(event.idContacto);
      final negociaciones = await _obtenerNegociaciones(event.idContacto);
      emit(ContactoDetalleCargado(
        contacto: contacto,
        negociaciones: negociaciones,
      ));
    } on AppException catch (e) {
      emit(ContactoDetalleError(e.message));
    } catch (_) {
      emit(const ContactoDetalleError(
        'Error al cargar el detalle de contacto.',
      ));
    }
  }
}
