// lib/features/cobranza/presentation/bloc/cobranza_factura_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaBloc
    extends Bloc<CobranzaFacturaEvent, CobranzaFacturaState> {
  CobranzaFacturaBloc({
    required int idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String idCondicion,
    required String condicion,
  }) : super(
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
    on<GuardarBorradorPressed>(_onGuardarBorrador);
    on<FacturarPressed>(_onFacturar);
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
    // TODO: conectar validación real con el endpoint
    emit(state.copyWith(planValidado: true));
  }

  void _onGuardarBorrador(
    GuardarBorradorPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    // TODO: implementar guardado de borrador
  }

  void _onFacturar(
    FacturarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    // TODO: implementar facturación real
  }
}
