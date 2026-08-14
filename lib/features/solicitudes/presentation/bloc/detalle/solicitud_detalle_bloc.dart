// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_bloc.dart

import 'dart:async';

import 'package:app_crm/core/errors/app_exception.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleBloc
    extends Bloc<SolicitudDetalleEvent, SolicitudDetalleState> {
  final GetDetalleSolicitudUseCase _getDetalleSolicitudUseCase;
  final GetSolicitudesUseCase _getSolicitudesUseCase;

  StreamSubscription<SolicitudUpdate>? _updateSub;
  String? _numSol;

  SolicitudDetalleBloc(
    this._getDetalleSolicitudUseCase,
    this._getSolicitudesUseCase,
  ) : super(const SolicitudDetalleInitial()) {
    on<SolicitudDetalleStarted>(_onStarted);
    on<SolicitudDetalleItemActualizado>(_onItemActualizado);

    _updateSub = SolicitudUpdateNotifier.instance.stream.listen((update) {
      if (!isClosed && update.numSol == _numSol) {
        add(SolicitudDetalleItemActualizado(update));
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
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
    _numSol = event.numSol;
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

  // Parchea el detalle (participante/facturación) y el resumen (Solicitud)
  // en memoria con lo que el wizard ya tiene calculado — sin llamar al
  // backend ni pasar por SolicitudDetalleLoading. Historial y el resto de
  // campos de Solicitud (estado/canal/asesor/oportunidad/fecha) no los toca
  // este flujo — nada en el wizard los modifica.
  void _onItemActualizado(
    SolicitudDetalleItemActualizado event,
    Emitter<SolicitudDetalleState> emit,
  ) {
    final current = state;
    if (current is! SolicitudDetalleSuccess) return;

    final u = event.update;
    final s = u.solicitante;
    final f = u.facturacion;
    final esRuc = f != null && u.facturacionEsRuc;

    final detalleActualizado = current.detalle.copyWith(
      tipoDocumentoId: s.tipoDocId,
      numDoc: s.numDoc,
      cargo: s.cargo,
      celular: s.celular,
      correo: s.correo,
      facTipoComprobante: f?.comprobante ?? '',
      facRazonSocial: esRuc ? f.nombresRazon : '',
      facRuc: esRuc ? f.numDoc : '',
      facDireccion: f?.direccion ?? '',
      facNumDoc: (f != null && !esRuc) ? f.numDoc : '',
      facNombres: (f != null && !esRuc) ? f.nombresRazon : '',
      facApellidoPaterno: (f != null && !esRuc) ? f.apellidoPaterno : '',
      facApellidoMaterno: (f != null && !esRuc) ? f.apellidoMaterno : '',
    );

    final solicitudActualizada = current.solicitud?.copyWith(
      nombre: s.nombres,
      apellidoPaterno: s.apellidoPaterno,
      apellidoMaterno: s.apellidoMaterno,
      nombreEmpresa: s.razonSocial,
      cargo: s.cargo,
      correo: s.correo,
      telefono: s.celular,
      tipoPersona: u.tipoPersona,
      monto: u.montoTotal,
    );

    emit(SolicitudDetalleSuccess(detalleActualizado, solicitudActualizada));
  }
}
