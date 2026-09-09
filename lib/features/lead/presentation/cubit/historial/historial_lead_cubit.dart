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

  /// [silencioso]: recarga en segundo plano (ej. tras crear/editar una
  /// negociación, que escribe una fila en T_LEAD_SEGUIMIENTO) — conserva la
  /// lista ya visible en vez de mostrar el spinner de pantalla completa, y si
  /// la red falla no rompe la vista con un error.
  Future<void> cargarHistorialPorContacto(
    int idContacto, {
    bool silencioso = false,
  }) async {
    if (!silencioso || state is! HistorialLeadSuccess) {
      emit(const HistorialLeadLoading());
    }
    try {
      final eventos = await _obtenerHistorialPorContactoUseCase.call(
        idContacto,
      );
      emit(HistorialLeadSuccess(eventos: eventos));
    } catch (e) {
      if (!silencioso || state is! HistorialLeadSuccess) {
        emit(HistorialLeadError(mensaje: e.toString()));
      }
    }
  }
}
