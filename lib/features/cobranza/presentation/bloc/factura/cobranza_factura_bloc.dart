// lib/features/cobranza/presentation/bloc/cobranza_factura_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaBloc
    extends Bloc<CobranzaFacturaEvent, CobranzaFacturaState> {
  final GuardarBorradorUseCase _guardarBorrador;
  final FacturarContadoUseCase _facturarContado;

  CobranzaFacturaBloc({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String idCondicion,
    required String condicion,
    required GuardarBorradorUseCase guardarBorradorUseCase,
    required FacturarContadoUseCase facturarContadoUseCase,
  })  : _guardarBorrador = guardarBorradorUseCase,
        _facturarContado = facturarContadoUseCase,
        super(
          CobranzaFacturaState(
            idCobranza: idCobranza,
            nombre: nombre,
            oportunidad: oportunidad,
            montoTotal: montoTotal,
            idCondicion: idCondicion,
            condicion: condicion,
          ),
        ) {
    on<CondicionChanged>(_onCondicionChanged);
    on<FechaVencimientoChanged>(_onFechaChanged);
    on<OcChanged>(_onOcChanged);
    on<DescripcionChanged>(_onDescripcionChanged);
    on<HojaAceptacionChanged>(_onHojaChanged);
    on<PlanValidarPressed>(_onPlanValidar);
    on<GuardarBorradorPressed>(_onGuardarBorradorPressed);
    on<FacturarPressed>(_onFacturarPressed);
  }

  void _onCondicionChanged(
    CondicionChanged event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(
      idCondicion: event.idCondicion,
      condicion: event.condicion,
      planValidado: false,
      fechaVencimiento: '',
      status: CobranzaFacturaStatus.idle,
    ));
  }

  void _onFechaChanged(
    FechaVencimientoChanged event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(fechaVencimiento: event.fecha));
  }

  void _onOcChanged(OcChanged event, Emitter<CobranzaFacturaState> emit) {
    emit(state.copyWith(oc: event.valor));
  }

  void _onDescripcionChanged(
    DescripcionChanged event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(descripcion: event.valor));
  }

  void _onHojaChanged(
    HojaAceptacionChanged event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(hojaAceptacion: event.valor));
  }

  void _onPlanValidar(
    PlanValidarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(planValidado: true));
  }

  Future<void> _onGuardarBorradorPressed(
    GuardarBorradorPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) async {
    emit(state.copyWith(status: CobranzaFacturaStatus.loading));
    try {
      final result = await _guardarBorrador(state.idCobranza);
      switch (result) {
        case CrudOk():
          emit(state.copyWith(status: CobranzaFacturaStatus.borradorGuardado));
        case CrudAlert(:final message):
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: message,
          ));
        case CrudError(:final message):
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: message,
          ));
        case CrudNoInternet():
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: 'Sin conexión a Internet.',
          ));
        case CrudEmpty():
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: 'Sin respuesta del servidor.',
          ));
      }
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(
        status: CobranzaFacturaStatus.error,
        mensajeError: e.toString(),
      ));
    }
  }

  Future<void> _onFacturarPressed(
    FacturarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) async {
    if (state.esCredito) {
      emit(state.copyWith(status: CobranzaFacturaStatus.continuarPlan));
      return;
    }

    emit(state.copyWith(status: CobranzaFacturaStatus.loading));
    try {
      final result = await _facturarContado(state.idCobranza);
      switch (result) {
        case CrudOk():
          emit(state.copyWith(status: CobranzaFacturaStatus.facturadoOk));
        case CrudAlert(:final message):
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: message,
          ));
        case CrudError(:final message):
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: message,
          ));
        case CrudNoInternet():
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: 'Sin conexión a Internet.',
          ));
        case CrudEmpty():
          emit(state.copyWith(
            status: CobranzaFacturaStatus.error,
            mensajeError: 'Sin respuesta del servidor.',
          ));
      }
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(
        status: CobranzaFacturaStatus.error,
        mensajeError: e.toString(),
      ));
    }
  }
}
