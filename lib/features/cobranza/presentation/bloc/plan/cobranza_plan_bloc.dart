// lib/features/cobranza/presentation/bloc/plan/cobranza_plan_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

// Ojo: este bloc NO llama al backend — "Guardar plan" solo valida y
// confirma localmente. El RC real (guardarPlanCredito) se dispara recién al
// presionar "Facturar" en CobranzaFacturaPage, ver cobranza/CLAUDE.md.
class CobranzaPlanBloc extends Bloc<CobranzaPlanEvent, CobranzaPlanState> {
  CobranzaPlanBloc({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required double detraccion,
    required double importeCredito,
    List<CuotaPlan> cuotasIniciales = const [],
  })  : super(_estadoInicial(
          idCobranza: idCobranza,
          nombre: nombre,
          oportunidad: oportunidad,
          montoTotal: montoTotal,
          moneda: moneda,
          detraccion: detraccion,
          importeCredito: importeCredito,
          cuotasIniciales: cuotasIniciales,
        )) {
    on<CobranzaPlanStarted>(_onStarted);
    on<NumCuotasDeseadasChanged>(_onNumCuotasDeseadasChanged);
    on<VistaPreviaPressed>(_onVistaPrevia);
    on<LimpiarPressed>(_onLimpiar);
    on<CuotaSeleccionada>(_onCuotaSeleccionada);
    on<DiasChanged>(_onDiasChanged);
    on<FechaCuotaChanged>(_onFechaChanged);
    on<ModificarCuotaPressed>(_onModificarCuota);
    on<GuardarPlanPressed>(_onGuardarPlan);
  }

  static String _fechaMasDias(int dias) =>
      DateTime.now().add(Duration(days: dias)).format(AppDateFormat.shortDate);

  static CobranzaPlanState _estadoInicial({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required double detraccion,
    required double importeCredito,
    required List<CuotaPlan> cuotasIniciales,
  }) {
    // Si ya había un plan configurado antes (el usuario volvió a "Validar"
    // tras haberlo guardado localmente), se restaura tal cual en vez de
    // resetear siempre a la cuota única por defecto.
    final cuotas = cuotasIniciales.isNotEmpty
        ? cuotasIniciales
        : [CuotaPlan(numeroCuota: 1, fechaVencimiento: _fechaMasDias(7), monto: importeCredito)];

    return CobranzaPlanState(
      idCobranza: idCobranza,
      nombre: nombre,
      oportunidad: oportunidad,
      montoTotal: montoTotal,
      moneda: moneda,
      detraccion: detraccion,
      cuotas: cuotas,
      numCuotasDeseadas: cuotas.length,
      formNumeroCuota: 0,
      formDias: 7,
      formFecha: _fechaMasDias(7),
    );
  }

  void _onStarted(CobranzaPlanStarted event, Emitter<CobranzaPlanState> emit) {}

  void _onNumCuotasDeseadasChanged(
    NumCuotasDeseadasChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    if (event.valor <= 0) return;
    emit(state.copyWith(numCuotasDeseadas: event.valor));
  }

  // Regenera todo el cronograma: numCuotasDeseadas cuotas, monto = importe
  // comprobante / N cada una, días por defecto 7*i (i=1..N) — el único dato
  // confirmado es que la cuota única por defecto es 7 días; ajustable a mano
  // después vía "Modificar" en cada cuota.
  void _onVistaPrevia(
    VistaPreviaPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    final n = state.numCuotasDeseadas;
    final montoPorCuota = state.montoTotal / n;

    final cuotas = List<CuotaPlan>.generate(
      n,
      (i) => CuotaPlan(
        numeroCuota: i + 1,
        fechaVencimiento: _fechaMasDias(7 * (i + 1)),
        monto: montoPorCuota,
      ),
    );

    emit(state.copyWith(
      cuotas: cuotas,
      formNumeroCuota: 0,
      status: CobranzaPlanStatus.idle,
    ));
  }

  void _onLimpiar(
    LimpiarPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(
      cuotas: const [],
      numCuotasDeseadas: 1,
      formNumeroCuota: 0,
      formDias: 7,
      formFecha: _fechaMasDias(7),
      status: CobranzaPlanStatus.idle,
    ));
  }

  void _onCuotaSeleccionada(
    CuotaSeleccionada event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(
      formNumeroCuota: event.cuota.numeroCuota,
      formDias: diasDesdeHoy(event.cuota.fechaVencimiento),
      formFecha: event.cuota.fechaVencimiento,
    ));
  }

  void _onDiasChanged(
    DiasChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(formDias: event.dias, formFecha: _fechaMasDias(event.dias)));
  }

  void _onFechaChanged(
    FechaCuotaChanged event,
    Emitter<CobranzaPlanState> emit,
  ) {
    emit(state.copyWith(formFecha: event.fecha));
  }

  // Aplica Días/Fecha del formulario a la cuota seleccionada. Regla de
  // negocio: una cuota no puede vencer antes que la cuota anterior.
  void _onModificarCuota(
    ModificarCuotaPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    if (state.formNumeroCuota == 0) {
      emit(state.copyWith(
        status: CobranzaPlanStatus.error,
        mensajeError: 'Selecciona una cuota del cronograma para modificarla.',
      ));
      emit(state.copyWith(status: CobranzaPlanStatus.idle));
      return;
    }

    final lista = List<CuotaPlan>.from(state.cuotas);
    final idx = lista.indexWhere((c) => c.numeroCuota == state.formNumeroCuota);
    if (idx < 0) return;

    final anterior = lista.where((c) => c.numeroCuota == state.formNumeroCuota - 1).firstOrNull;
    if (anterior != null) {
      final fechaNueva = parseFechaCorta(state.formFecha);
      final fechaAnterior = parseFechaCorta(anterior.fechaVencimiento);
      if (fechaNueva != null && fechaAnterior != null && fechaNueva.isBefore(fechaAnterior)) {
        emit(state.copyWith(
          status: CobranzaPlanStatus.error,
          mensajeError:
              'La cuota ${state.formNumeroCuota} no puede vencer antes que la cuota ${anterior.numeroCuota}.',
        ));
        emit(state.copyWith(status: CobranzaPlanStatus.idle));
        return;
      }
    }

    lista[idx] = lista[idx].copyWith(fechaVencimiento: state.formFecha);
    emit(state.copyWith(cuotas: lista, status: CobranzaPlanStatus.idle));
  }

  // "Guardar plan" — solo valida y confirma localmente (no llama al
  // backend). CobranzaPlanPage hace pop con las cuotas + fechaMasAlta al ver
  // este status; el RC real lo dispara CobranzaFacturaPage al facturar.
  void _onGuardarPlan(
    GuardarPlanPressed event,
    Emitter<CobranzaPlanState> emit,
  ) {
    if (state.cuotas.isEmpty) {
      emit(state.copyWith(
        status: CobranzaPlanStatus.error,
        mensajeError: 'Agrega al menos una cuota antes de guardar.',
      ));
      emit(state.copyWith(status: CobranzaPlanStatus.idle));
      return;
    }
    emit(state.copyWith(status: CobranzaPlanStatus.guardado));
  }
}
