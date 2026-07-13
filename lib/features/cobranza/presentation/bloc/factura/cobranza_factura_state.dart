// lib/features/cobranza/presentation/bloc/factura/cobranza_factura_state.dart

import 'package:app_crm/core/index_core.dart';

// ── Estado de operación del formulario de facturación ────────────────────────

enum CobranzaFacturaStatus {
  idle,
  loading,
  facturadoOk,
  continuarPlan,
  error,
}

// ── Modelo para el combo de condición de pago ────────────────────────────────

class CondicionItem with Comboable {
  final String id;
  final String label;
  const CondicionItem({required this.id, required this.label});

  @override
  List<dynamic> get fields => [id, label];
}

const condicionesDisponibles = [
  CondicionItem(id: 'C', label: 'Contado'),
  CondicionItem(id: 'CR', label: 'Crédito'),
];

// ── Estado del formulario de facturación ─────────────────────────────────────

class CobranzaFacturaState {
  // Datos del cobro padre (read-only)
  final String idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final String moneda;

  // Formulario
  final String idCondicion;
  final String condicion;
  final String fechaVencimiento;
  final String oc;
  final String descripcion;
  final String hojaAceptacion;
  final bool planValidado;

  // ── Estado de la operación ──────────────────────────────────
  final CobranzaFacturaStatus status;
  final String? mensajeError;

  // ── Calculados para el resumen ──────────────────────────────
  // Detracción 12% sobre el importe del comprobante (confirmado: 460.20*0.12=55.22)
  double get detraccion => montoTotal * 0.12;
  double get importeCredito => montoTotal - detraccion;
  int get numCuotas => 1;
  double get pagoACuenta => 0.0;
  double get saldo => montoTotal - pagoACuenta;

  bool get esCredito => idCondicion == 'CR';

  const CobranzaFacturaState({
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    this.moneda = '',
    required this.idCondicion,
    required this.condicion,
    this.fechaVencimiento = '',
    this.oc = '',
    this.descripcion = '',
    this.hojaAceptacion = '',
    this.planValidado = false,
    this.status = CobranzaFacturaStatus.idle,
    this.mensajeError,
  });

  CobranzaFacturaState copyWith({
    String? idCondicion,
    String? condicion,
    String? fechaVencimiento,
    String? oc,
    String? descripcion,
    String? hojaAceptacion,
    bool? planValidado,
    CobranzaFacturaStatus? status,
    String? mensajeError,
  }) {
    return CobranzaFacturaState(
      idCobranza: idCobranza,
      nombre: nombre,
      oportunidad: oportunidad,
      montoTotal: montoTotal,
      moneda: moneda,
      idCondicion: idCondicion ?? this.idCondicion,
      condicion: condicion ?? this.condicion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      oc: oc ?? this.oc,
      descripcion: descripcion ?? this.descripcion,
      hojaAceptacion: hojaAceptacion ?? this.hojaAceptacion,
      planValidado: planValidado ?? this.planValidado,
      status: status ?? this.status,
      mensajeError: mensajeError ?? this.mensajeError,
    );
  }
}
