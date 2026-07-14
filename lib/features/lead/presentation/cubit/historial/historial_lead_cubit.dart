// lib/features/lead/presentation/cubit/historial/historial_lead_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialLeadCubit extends Cubit<HistorialLeadState> {
  final GetHistorialComentarios? _obtenerHistorialUseCase;
  final GetHistorialSeguimiento? _obtenerHistorialSeguimientoUseCase;

  // Cada pantalla que usa HistorialTab solo necesita una de las dos fuentes
  // (Contacto → comentarios por número 'LCG', Chat → seguimiento por lead
  // 'LH'), por eso ambas son opcionales — cada Page solo instancia la suya.
  HistorialLeadCubit({
    GetHistorialComentarios? obtenerHistorialUseCase,
    GetHistorialSeguimiento? obtenerHistorialSeguimientoUseCase,
  }) : _obtenerHistorialUseCase = obtenerHistorialUseCase,
       _obtenerHistorialSeguimientoUseCase = obtenerHistorialSeguimientoUseCase,
       super(const HistorialLeadInitial());

  Future<void> cargarHistorial(int idNumero) async {
    emit(const HistorialLeadLoading());
    try {
      final eventos = await _obtenerHistorialUseCase!.call(idNumero);
      emit(HistorialLeadSuccess(eventos: eventos));
    } catch (e) {
      emit(HistorialLeadError(mensaje: e.toString()));
    }
  }

  Future<void> cargarHistorialSeguimiento(int idLead) async {
    emit(const HistorialLeadLoading());
    try {
      final eventos = await _obtenerHistorialSeguimientoUseCase!.call(idLead);
      emit(HistorialLeadSuccess(eventos: eventos));
    } catch (e) {
      emit(HistorialLeadError(mensaje: e.toString()));
    }
  }
}
