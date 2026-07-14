// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_bloc.dart

import 'package:app_crm/core/errors/app_exception.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleBloc
    extends Bloc<SolicitudDetalleEvent, SolicitudDetalleState> {
  final GetDetalleSolicitudUseCase _getDetalleSolicitudUseCase;
  final GetSolicitudesUseCase _getSolicitudesUseCase;

  SolicitudDetalleBloc(
    this._getDetalleSolicitudUseCase,
    this._getSolicitudesUseCase,
  ) : super(const SolicitudDetalleInitial()) {
    on<SolicitudDetalleStarted>(_onStarted);
  }

  // Trae el detalle ('DV': participante/facturación/historial) y la lista
  // completa ('LS', de donde se saca nombre/estado/monto/asesor/oportunidad)
  // en paralelo, siempre en red — nunca se reusa lo que llegó por
  // navegación, así la pantalla muestra lo más actual sin importar de dónde
  // vino (lista con caché vieja, o un Solicitud "de paso" armado a mano
  // desde una Negociacion con campos vacíos).
  Future<void> _onStarted(
    SolicitudDetalleStarted event,
    Emitter<SolicitudDetalleState> emit,
  ) async {
    emit(const SolicitudDetalleLoading());
    try {
      final resultados = await Future.wait([
        _getDetalleSolicitudUseCase(event.numSol),
        _getSolicitudesUseCase(),
      ]);
      final detalle = resultados[0] as SolicitudDetalle;
      final lista = resultados[1] as List<Solicitud>;
      final solicitud = lista
          .where((s) => s.idSolicitud == event.numSol)
          .firstOrNull;
      emit(SolicitudDetalleSuccess(detalle, solicitud));
    } on AppException catch (e) {
      emit(SolicitudDetalleError(e.message));
    } catch (_) {
      emit(const SolicitudDetalleError('No se pudo cargar el detalle.'));
    }
  }
}
