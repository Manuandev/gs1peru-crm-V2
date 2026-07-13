// lib/features/cobranza/presentation/bloc/plan/cobranza_plan_state.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

// ── Estado de operación ───────────────────────────────────────────────────────

enum CobranzaPlanStatus { idle, loading, guardado, error }

// ── Estado del BLoC ───────────────────────────────────────────────────────────

class CobranzaPlanState {
  // Datos del cobro padre (read-only)
  final String idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final String moneda;
  final double detraccion;

  double get importeCredito => montoTotal - detraccion;

  // Cronograma generado
  final List<CuotaPlan> cuotas;

  double get totalCuotas => cuotas.fold(0.0, (sum, c) => sum + c.monto);

  // Fecha de vencimiento más alta entre las cuotas — es lo que se devuelve a
  // CobranzaFacturaPage al guardar el plan, para actualizar su campo "Fecha
  // de vencimiento de la factura".
  String get fechaMasAlta {
    if (cuotas.isEmpty) return '';
    var maxTexto = cuotas.first.fechaVencimiento;
    DateTime? maxFecha = parseFechaCorta(maxTexto);
    for (final c in cuotas.skip(1)) {
      final f = parseFechaCorta(c.fechaVencimiento);
      if (f != null && (maxFecha == null || f.isAfter(maxFecha))) {
        maxFecha = f;
        maxTexto = c.fechaVencimiento;
      }
    }
    return maxTexto;
  }

  // "¿En cuántas cuotas?" — resumen
  final int numCuotasDeseadas;

  // Formulario "Configurar cuota" — N° cuota es de solo lectura (se llena al
  // tocar una fila del cronograma), Días/Fecha son los únicos editables.
  final int formNumeroCuota; // 0 = ninguna cuota seleccionada
  final int formDias;
  final String formFecha;

  // Estado de la operación
  final CobranzaPlanStatus status;
  final String? mensajeError;

  const CobranzaPlanState({
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.moneda,
    required this.detraccion,
    required this.cuotas,
    required this.numCuotasDeseadas,
    required this.formNumeroCuota,
    required this.formDias,
    required this.formFecha,
    this.status = CobranzaPlanStatus.idle,
    this.mensajeError,
  });

  CobranzaPlanState copyWith({
    List<CuotaPlan>? cuotas,
    int? numCuotasDeseadas,
    int? formNumeroCuota,
    int? formDias,
    String? formFecha,
    CobranzaPlanStatus? status,
    String? mensajeError,
  }) {
    return CobranzaPlanState(
      idCobranza: idCobranza,
      nombre: nombre,
      oportunidad: oportunidad,
      montoTotal: montoTotal,
      moneda: moneda,
      detraccion: detraccion,
      cuotas: cuotas ?? this.cuotas,
      numCuotasDeseadas: numCuotasDeseadas ?? this.numCuotasDeseadas,
      formNumeroCuota: formNumeroCuota ?? this.formNumeroCuota,
      formDias: formDias ?? this.formDias,
      formFecha: formFecha ?? this.formFecha,
      status: status ?? this.status,
      mensajeError: mensajeError ?? this.mensajeError,
    );
  }
}
