// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_bloc.dart

import 'package:app_crm/core/errors/app_exception.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleBloc
    extends Bloc<SolicitudDetalleEvent, SolicitudDetalleState> {
  final GetDetalleSolicitudUseCase _getDetalleSolicitudUseCase;

  SolicitudDetalleBloc(this._getDetalleSolicitudUseCase)
    : super(const SolicitudDetalleInitial()) {
    on<SolicitudDetalleStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SolicitudDetalleStarted event,
    Emitter<SolicitudDetalleState> emit,
  ) async {
    emit(const SolicitudDetalleLoading());
    try {
      final detalle = await _getDetalleSolicitudUseCase(event.numSol);
      emit(SolicitudDetalleSuccess(detalle));
    } on AppException catch (e) {
      emit(SolicitudDetalleError(e.message));
    } catch (_) {
      emit(const SolicitudDetalleError('No se pudo cargar el detalle.'));
    }
  }
}
