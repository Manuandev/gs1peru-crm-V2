// lib/features/lead/presentation/cubit/historial/historial_lead_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialLeadCubit extends Cubit<HistorialLeadState> {
  final GetHistorialSeguimientoPorNumero _obtenerHistorialPorNumeroUseCase;

  HistorialLeadCubit({
    required GetHistorialSeguimientoPorNumero obtenerHistorialPorNumeroUseCase,
  }) : _obtenerHistorialPorNumeroUseCase = obtenerHistorialPorNumeroUseCase,
       super(const HistorialLeadInitial());

  Future<void> cargarHistorialPorNumero(int idNumero) async {
    emit(const HistorialLeadLoading());
    try {
      final eventos = await _obtenerHistorialPorNumeroUseCase.call(idNumero);
      emit(HistorialLeadSuccess(eventos: eventos));
    } catch (e) {
      emit(HistorialLeadError(mensaje: e.toString()));
    }
  }
}
