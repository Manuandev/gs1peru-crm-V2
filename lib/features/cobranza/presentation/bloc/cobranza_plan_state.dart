// lib/features/cobranza/presentation/bloc/cobranza_plan_state.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

// ── Estado de operación ───────────────────────────────────────────────────────

enum CobranzaPlanStatus { idle, loading, guardado, limpiado, error }

// ── Estado del BLoC ───────────────────────────────────────────────────────────

class CobranzaPlanState {
  // Datos del cobro padre (read-only)
  final int idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final double detraccion;

  double get importeCredito => montoTotal - detraccion;

  // Cronograma generado
  final List<CuotaPlan> cuotas;

  double get totalCuotas =>
      cuotas.fold(0.0, (sum, c) => sum + c.monto);

  // Formulario "Configurar cuota"
  final int formNumeroCuota;
  final int formDias;
  final String formFecha;
  final double formMonto;

  // Estado de la operación
  final CobranzaPlanStatus status;
  final String? mensajeError;

  const CobranzaPlanState({
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.detraccion,
    required this.cuotas,
    required this.formNumeroCuota,
    required this.formDias,
    required this.formFecha,
    required this.formMonto,
    this.status = CobranzaPlanStatus.idle,
    this.mensajeError,
  });

  CobranzaPlanState copyWith({
    List<CuotaPlan>? cuotas,
    int? formNumeroCuota,
    int? formDias,
    String? formFecha,
    double? formMonto,
    CobranzaPlanStatus? status,
    String? mensajeError,
  }) {
    return CobranzaPlanState(
      idCobranza: idCobranza,
      nombre: nombre,
      oportunidad: oportunidad,
      montoTotal: montoTotal,
      detraccion: detraccion,
      cuotas: cuotas ?? this.cuotas,
      formNumeroCuota: formNumeroCuota ?? this.formNumeroCuota,
      formDias: formDias ?? this.formDias,
      formFecha: formFecha ?? this.formFecha,
      formMonto: formMonto ?? this.formMonto,
      status: status ?? this.status,
      mensajeError: mensajeError ?? this.mensajeError,
    );
  }
}
