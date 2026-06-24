// lib/features/lead/presentation/cubit/negociaciones/negociaciones_cubit.dart
//
// Cubit migrado a NegociacionesCubit (ver bloc/negociaciones_cubit/).
// Este archivo se mantiene por compatibilidad de imports en LeadDetailSheet.
// La lógica real vive en presentation/bloc/negociaciones_cubit/.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart';

class NegociacionesCubit extends Cubit<NegociacionesState> {
  NegociacionesCubit() : super(const NegociacionesInitial());

  // TODO: reemplazar por ObtenerNegociacionesUseCase cuando el SP esté disponible
  Future<void> cargarNegociaciones(int leadId) async {
    emit(const NegociacionesLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const NegociacionesSuccess(negociaciones: []));
    } catch (e) {
      emit(NegociacionesError(mensaje: e.toString()));
    }
  }
}
