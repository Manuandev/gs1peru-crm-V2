// lib/features/cobranza/presentation/bloc/factura/cobranza_factura_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaBloc
    extends Bloc<CobranzaFacturaEvent, CobranzaFacturaState> {
  final FacturarContadoUseCase _facturarContado;

  CobranzaFacturaBloc({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required String idCondicion,
    required String condicion,
    required FacturarContadoUseCase facturarContadoUseCase,
  })  : _facturarContado = facturarContadoUseCase,
        super(
          CobranzaFacturaState(
            idCobranza: idCobranza,
            nombre: nombre,
            oportunidad: oportunidad,
            montoTotal: montoTotal,
            moneda: moneda,
            idCondicion: idCondicion,
            condicion: condicion,
            fechaVencimiento: idCondicion == 'CR' ? _hoy() : '',
          ),
        ) {
    on<CondicionChanged>(_onCondicionChanged);
    on<FechaVencimientoChanged>(_onFechaChanged);
    on<OcChanged>(_onOcChanged);
    on<DescripcionChanged>(_onDescripcionChanged);
    on<HojaAceptacionChanged>(_onHojaChanged);
    on<PlanValidarPressed>(_onPlanValidar);
    on<PlanGuardado>(_onPlanGuardado);
    on<FacturarPressed>(_onFacturarPressed);
  }

  static String _hoy() => DateTime.now().format(AppDateFormat.shortDate);

  void _onCondicionChanged(
    CondicionChanged event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    final esCredito = event.idCondicion == 'CR';
    emit(state.copyWith(
      idCondicion: event.idCondicion,
      condicion: event.condicion,
      planValidado: false,
      fechaVencimiento: esCredito ? _hoy() : '',
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

  // "Validar plan de crédito" — lleva al usuario a CobranzaPlanPage (status
  // continuarPlan, escuchado en CobranzaFacturaPage). Ojo: esto NO marca
  // planValidado — eso solo pasa si el usuario efectivamente guarda el plan
  // (ver _onPlanGuardado); si solo entra y vuelve sin guardar, no debe
  // quedar marcado como validado. Se resetea a idle justo después para
  // poder volver a disparar la navegación si presiona "Validar" de nuevo.
  void _onPlanValidar(
    PlanValidarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(status: CobranzaFacturaStatus.continuarPlan));
    emit(state.copyWith(status: CobranzaFacturaStatus.idle));
  }

  // Resultado de CobranzaPlanPage tras guardar el plan de crédito — recién
  // acá se marca planValidado y se actualiza la fecha de vencimiento con la
  // más alta de las cuotas guardadas.
  void _onPlanGuardado(
    PlanGuardado event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(
      fechaVencimiento: event.fechaVencimiento,
      planValidado: true,
    ));
  }

  Future<void> _onFacturarPressed(
    FacturarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) async {
    if (state.esCredito && !state.planValidado) {
      emit(state.copyWith(
        status: CobranzaFacturaStatus.error,
        mensajeError: 'Valida el plan de crédito antes de facturar.',
      ));
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
