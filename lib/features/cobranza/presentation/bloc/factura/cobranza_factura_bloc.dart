// lib/features/cobranza/presentation/bloc/factura/cobranza_factura_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaBloc
    extends Bloc<CobranzaFacturaEvent, CobranzaFacturaState> {
  final CambiarEstadoFacturarUseCase _cambiarEstadoFacturar;
  final GuardarPlanCreditoUseCase _guardarPlanCredito;

  CobranzaFacturaBloc({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required String monedaId,
    required String idCondicion,
    required String condicion,
    required String tipoComprobante,
    required double montoTotalEnSoles,
    required CambiarEstadoFacturarUseCase cambiarEstadoFacturarUseCase,
    required GuardarPlanCreditoUseCase guardarPlanCreditoUseCase,
  })  : _cambiarEstadoFacturar = cambiarEstadoFacturarUseCase,
        _guardarPlanCredito = guardarPlanCreditoUseCase,
        super(
          CobranzaFacturaState(
            idCobranza: idCobranza,
            nombre: nombre,
            oportunidad: oportunidad,
            montoTotal: montoTotal,
            moneda: moneda,
            monedaId: monedaId,
            idCondicion: idCondicion,
            condicion: condicion,
            tipoComprobante: tipoComprobante,
            montoTotalEnSoles: montoTotalEnSoles,
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

  // 'CR'/'C' (convención de la app) -> '1'/'2' (CONDICION_PAGO del SP).
  static String _condicionPagoBackend(String idCondicion) =>
      idCondicion == 'CR' ? '1' : '2';

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
  // continuarPlan, escuchado en CobranzaFacturaPage). No marca planValidado
  // — eso solo pasa si el usuario efectivamente guarda el plan (ver
  // _onPlanGuardado). Se resetea a idle justo después para poder volver a
  // disparar la navegación si presiona "Validar" de nuevo.
  void _onPlanValidar(
    PlanValidarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(status: CobranzaFacturaStatus.continuarPlan));
    emit(state.copyWith(status: CobranzaFacturaStatus.idle));
  }

  // Resultado de CobranzaPlanPage tras guardar el plan localmente — guarda
  // las cuotas (se mandan recién al facturar) y actualiza la fecha de
  // vencimiento con la más alta de las cuotas.
  void _onPlanGuardado(
    PlanGuardado event,
    Emitter<CobranzaFacturaState> emit,
  ) {
    emit(state.copyWith(
      fechaVencimiento: event.fechaVencimiento,
      cuotasCredito: event.cuotas,
      planValidado: true,
    ));
  }

  Future<void> _onFacturarPressed(
    FacturarPressed event,
    Emitter<CobranzaFacturaState> emit,
  ) async {
    // O/C ya se valida inline en el Form de la vista (rojo bajo el campo,
    // sin snackbar) — acá solo lo que el Form no puede cubrir (crédito).
    if (state.esCredito) {
      if (!state.planValidado) {
        emit(state.copyWith(
          status: CobranzaFacturaStatus.error,
          mensajeError: 'Valida el plan de crédito antes de facturar.',
        ));
        emit(state.copyWith(status: CobranzaFacturaStatus.idle));
        return;
      }
      if (state.fechaVencimiento.trim().isEmpty) {
        emit(state.copyWith(
          status: CobranzaFacturaStatus.error,
          mensajeError: 'La fecha de vencimiento es obligatoria.',
        ));
        emit(state.copyWith(status: CobranzaFacturaStatus.idle));
        return;
      }
    }

    emit(state.copyWith(status: CobranzaFacturaStatus.loading));

    // Crédito: primero se guarda el plan (RC) — solo si sale bien se
    // continúa con el cambio de estado (UE). Contado: solo UE.
    if (state.esCredito) {
      final resultadoPlan = await _guardarPlanCredito(
        numSol: state.idCobranza,
        moneda: state.moneda,
        cuotas: state.cuotasCredito,
      );
      if (resultadoPlan is! CrudOk) {
        emit(state.copyWith(
          status: CobranzaFacturaStatus.error,
          mensajeError: _mensajeCrud(resultadoPlan) ?? 'No se pudo guardar el plan de crédito.',
        ));
        return;
      }
    }

    try {
      final result = await _cambiarEstadoFacturar(
        numSol: state.idCobranza,
        estado: '2', // Facturar — único valor que hace algo hoy en el SP
        condicionPago: _condicionPagoBackend(state.idCondicion),
        fechaVencimiento: state.esCredito ? state.fechaVencimiento : '',
        ordenCompra: state.oc,
        descripcionSugerida: state.descripcion,
        hojaAceptacion: state.hojaAceptacion,
      );
      switch (result) {
        case CrudOk():
          CobranzaUpdateNotifier.instance.notify(
            state.idCobranza,
            idEstado: 2,
            idCondicion: state.idCondicion,
            condicion: state.condicion,
          );
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

  String? _mensajeCrud(CrudResult result) => switch (result) {
        CrudAlert(:final message) => message,
        CrudError(:final message) => message,
        CrudNoInternet() => 'Sin conexión a Internet.',
        CrudEmpty() => 'Sin respuesta del servidor.',
        CrudOk() => null,
      };
}
