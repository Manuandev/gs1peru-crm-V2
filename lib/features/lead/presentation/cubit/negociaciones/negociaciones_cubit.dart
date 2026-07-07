// lib/features/lead/presentation/cubit/negociaciones/negociaciones_cubit.dart
//
// Cubit migrado a NegociacionesCubit (ver bloc/negociaciones_cubit/).
// Este archivo se mantiene por compatibilidad de imports en LeadDetailSheet.
// La lógica real vive en presentation/bloc/negociaciones_cubit/.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionesCubit extends Cubit<NegociacionesState> {
  final GetNegociacionesLead obtenerNegociacionesUseCase;
  
  NegociacionesCubit({required this.obtenerNegociacionesUseCase})
    : super(const NegociacionesInitial());

  Future<void> cargarNegociaciones(int idNumero) async {
    emit(const NegociacionesLoading());
    try {
      final negociaciones = await obtenerNegociacionesUseCase.call(idNumero);
      emit(NegociacionesSuccess(negociaciones: negociaciones));
    } catch (e) {
      emit(NegociacionesError(mensaje: e.toString()));
    }
  }
}
