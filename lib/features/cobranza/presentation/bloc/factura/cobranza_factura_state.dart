// lib/features/cobranza/presentation/bloc/factura/cobranza_factura_state.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

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
  // Tipo de comprobante ya decidido en la Facturación de la Solicitud de
  // origen (Boleta/Factura, texto tal cual lo manda el backend) — este
  // formulario no lo vuelve a elegir, solo lo necesita para la regla de
  // detracción (ver el getter más abajo).
  final String tipoComprobante;
  // Monto ya convertido a soles (con el tipo de cambio "venta" si la moneda
  // es USD, resuelto por CobranzaFacturaPage contra CatalogsBloc) — usado
  // SOLO para decidir si el monto supera el umbral de detracción (S/700),
  // nunca para ningún cálculo de importe/cuotas (esos siguen usando
  // montoTotal, en la moneda original).
  final double montoTotalEnSoles;

  // Formulario
  final String idCondicion;
  final String condicion;
  final String fechaVencimiento;
  final String oc;
  final String descripcion;
  final String hojaAceptacion;
  final bool planValidado;
  // Cuotas del plan de crédito ya "guardado" localmente (viene de
  // CobranzaPlanPage) — se mandan recién al presionar Facturar (task RC).
  final List<CuotaPlan> cuotasCredito;

  // ── Estado de la operación ──────────────────────────────────
  final CobranzaFacturaStatus status;
  final String? mensajeError;

  // ── Calculados para el resumen ──────────────────────────────
  // Regla de negocio (2026-08-19): la detracción SOLO aplica con
  // comprobante Factura (nunca Boleta) y solo si el monto, convertido a
  // soles si la moneda es USD (montoTotalEnSoles, ver arriba), es >= 700 —
  // debajo de ese umbral no hay detracción aunque sea Factura. Si no aplica,
  // detraccion es 0 e importeCredito == montoTotal.
  bool get esFactura => tipoComprobante.trim().toUpperCase().contains('FACTURA');
  bool get aplicaDetraccion => esFactura && montoTotalEnSoles >= 700;
  double get detraccion => aplicaDetraccion ? montoTotal * 0.12 : 0.0;
  double get importeCredito => montoTotal - detraccion;
  int get numCuotas => cuotasCredito.isEmpty ? 1 : cuotasCredito.length;
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
    this.tipoComprobante = '',
    this.montoTotalEnSoles = 0,
    this.fechaVencimiento = '',
    this.oc = '',
    this.descripcion = '',
    this.hojaAceptacion = '',
    this.planValidado = false,
    this.cuotasCredito = const [],
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
    List<CuotaPlan>? cuotasCredito,
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
      cuotasCredito: cuotasCredito ?? this.cuotasCredito,
      status: status ?? this.status,
      mensajeError: mensajeError ?? this.mensajeError,
    );
  }
}
