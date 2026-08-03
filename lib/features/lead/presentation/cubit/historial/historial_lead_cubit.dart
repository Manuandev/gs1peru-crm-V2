// lib/features/lead/presentation/cubit/historial/historial_lead_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialLeadCubit extends Cubit<HistorialLeadState> {
  final GetHistorialSeguimientoPorContacto _obtenerHistorialPorContactoUseCase;

  HistorialLeadCubit({
    required GetHistorialSeguimientoPorContacto
    obtenerHistorialPorContactoUseCase,
  }) : _obtenerHistorialPorContactoUseCase = obtenerHistorialPorContactoUseCase,
       super(const HistorialLeadInitial());

  Future<void> cargarHistorialPorContacto(int idContacto) async {
    emit(const HistorialLeadLoading());
    try {
      final eventos = await _obtenerHistorialPorContactoUseCase.call(
        idContacto,
      );
      emit(HistorialLeadSuccess(eventos: eventos));
    } catch (e) {
      emit(HistorialLeadError(mensaje: e.toString()));
    }
  }
}
