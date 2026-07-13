// lib/features/cobranza/presentation/bloc/detalle/cobranza_detalle_bloc.dart

import 'package:app_crm/core/errors/app_exception.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleBloc
    extends Bloc<CobranzaDetalleEvent, CobranzaDetalleState> {
  final GetDetalleCobranzaUseCase _getDetalleCobranzaUseCase;

  CobranzaDetalleBloc(this._getDetalleCobranzaUseCase)
      : super(const CobranzaDetalleInitial()) {
    on<CobranzaDetalleStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CobranzaDetalleStarted event,
    Emitter<CobranzaDetalleState> emit,
  ) async {
    emit(const CobranzaDetalleLoading());
    try {
      final detalle = await _getDetalleCobranzaUseCase(event.idCobranza);
      if (detalle == null) {
        emit(const CobranzaDetalleError('La cobranza no existe.'));
        return;
      }
      emit(CobranzaDetalleSuccess(detalle));
    } on AppException catch (e) {
      emit(CobranzaDetalleError(e.message));
    } catch (_) {
      emit(const CobranzaDetalleError('No se pudo cargar el detalle.'));
    }
  }
}
