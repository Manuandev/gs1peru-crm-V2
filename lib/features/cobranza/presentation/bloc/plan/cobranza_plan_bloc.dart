// lib/features/cobranza/presentation/bloc/cobranza_plan_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaPlanBloc extends Bloc<CobranzaPlanEvent, CobranzaPlanState> {
  final GuardarPlanCreditoUseCase _guardarPlanCredito;

  CobranzaPlanBloc({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required double detraccion,
    required double importeCredito,
    required GuardarPlanCreditoUseCase guardarPlanCreditoUseCase,
  })  : _guardarPlanCredito = guardarPlanCreditoUseCase,
        super(_estadoInicial(
          idCobranza: idCobranza,
          nombre: nombre,
          oportunidad: oportunidad,
          montoTotal: montoTotal,
          detraccion: detraccion,
          importeCredito: importeCredito,
        )) {
    on<CobranzaPlanStarted>(_onStarted);
    on<NumeroCuotaChanged>(_onNumeroCuotaChanged);
    on<DiasChanged>(_onDiasChanged);
    on<FechaCuotaChanged>(_onFechaChanged);
    on<MontoCuotaChanged>(_onMontoChanged);
    on<VistaPreviaPressed>(_onVistaPrevia);
    on<LimpiarPressed>(_onLimpiar);
    on<GuardarPlanPressed>(_onGuardarPlan);
  }

  static CobranzaPlanState _estadoInicial({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required double detraccion,
    required double importeCredito,
  }) {
    final fechaDefault = DateTime.now()
        .add(const Duration(days: 7))
        .format(AppDateFormat.shortDate);

    final cuotaInicial = CuotaPlan(
      numeroCuota: 1,
      fechaVencimiento: fechaDefault,
      monto: importeCredito,
    );

    return CobranzaPlanState(
      idCobranza: idCobranza,
      nombre: nombre,
      oportunidad: oportunidad,
      montoTotal: montoTotal,
      detraccion: detraccion,
      cuotas: [cuotaInicial],
      formNumeroCuota: 1,
      formDias: 7,
      formFecha: fechaDefault,
      formMonto: importeCredito,
    );
  }

  void _onStarted(CobranzaPlanStarted event, Emitter<CobranzaPlanState> emit) {}

  void _onNumeroCuotaChanged(
    NumeroCuotaChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(formNumeroCuota: event.valor));
  }

  void _onDiasChanged(
    DiasChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    final fecha = DateTime.now()
        .add(Duration(days: event.dias))
        .format(AppDateFormat.shortDate);
    emit(state.copyWith(formDias: event.dias, formFecha: fecha));
  }

  void _onFechaChanged(
    FechaCuotaChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(formFecha: event.fecha));
  }

  void _onMontoChanged(
    MontoCuotaChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(formMonto: event.monto));
  }

  void _onVistaPrevia(
    VistaPreviaPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    final nueva = CuotaPlan(
      numeroCuota: state.formNumeroCuota,
      fechaVencimiento: state.formFecha,
      monto: state.formMonto,
    );

    final lista = List<CuotaPlan>.from(state.cuotas);
    final idx = lista.indexWhere((c) => c.numeroCuota == nueva.numeroCuota);
    if (idx >= 0) {
      lista[idx] = nueva;
    } else {
      lista.add(nueva);
      lista.sort((a, b) => a.numeroCuota.compareTo(b.numeroCuota));
    }

    emit(state.copyWith(cuotas: lista, status: CobranzaPlanStatus.idle));
  }

  void _onLimpiar(
    LimpiarPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    final siguienteCuota = state.cuotas.length + 1;
    final fechaDefault = DateTime.now()
        .add(const Duration(days: 7))
        .format(AppDateFormat.shortDate);

    emit(state.copyWith(
      formNumeroCuota: siguienteCuota,
      formDias: 7,
      formFecha: fechaDefault,
      formMonto: state.importeCredito,
      status: CobranzaPlanStatus.limpiado,
    ));
  }

  Future<void> _onGuardarPlan(
    GuardarPlanPressed event,
    Emitter<CobranzaPlanState> emit,
  ) async {
    emit(state.copyWith(status: CobranzaPlanStatus.loading));
    try {
      final result = await _guardarPlanCredito(state.idCobranza, state.cuotas);
      switch (result) {
        case CrudOk():
          emit(state.copyWith(status: CobranzaPlanStatus.guardado));
        case CrudAlert(:final message):
          emit(state.copyWith(
            status: CobranzaPlanStatus.error,
            mensajeError: message,
          ));
        case CrudError(:final message):
          emit(state.copyWith(
            status: CobranzaPlanStatus.error,
            mensajeError: message,
          ));
        case CrudNoInternet():
          emit(state.copyWith(
            status: CobranzaPlanStatus.error,
            mensajeError: 'Sin conexión a Internet.',
          ));
        case CrudEmpty():
          emit(state.copyWith(
            status: CobranzaPlanStatus.error,
            mensajeError: 'Sin respuesta del servidor.',
          ));
      }
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(
        status: CobranzaPlanStatus.error,
        mensajeError: e.toString(),
      ));
    }
  }
}
