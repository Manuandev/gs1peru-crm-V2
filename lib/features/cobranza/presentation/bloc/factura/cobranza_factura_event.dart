// lib/features/cobranza/presentation/bloc/factura/cobranza_factura_event.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaFacturaEvent {
  const CobranzaFacturaEvent();
}

// Carga inicial con los datos del cobro padre
class CobranzaFacturaStarted extends CobranzaFacturaEvent {
  final String idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final String idCondicion;
  final String condicion;
  const CobranzaFacturaStarted({
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.idCondicion,
    required this.condicion,
  });
}

// Cambio de condición de pago (Contado / Crédito)
class CondicionChanged extends CobranzaFacturaEvent {
  final String idCondicion;
  final String condicion;
  const CondicionChanged(this.idCondicion, this.condicion);
}

class FechaVencimientoChanged extends CobranzaFacturaEvent {
  final String fecha;
  const FechaVencimientoChanged(this.fecha);
}

class OcChanged extends CobranzaFacturaEvent {
  final String valor;
  const OcChanged(this.valor);
}

class DescripcionChanged extends CobranzaFacturaEvent {
  final String valor;
  const DescripcionChanged(this.valor);
}

class HojaAceptacionChanged extends CobranzaFacturaEvent {
  final String valor;
  const HojaAceptacionChanged(this.valor);
}

class PlanValidarPressed extends CobranzaFacturaEvent {
  const PlanValidarPressed();
}

// Resultado al volver de CobranzaPlanPage tras guardar el plan — fecha de
// vencimiento más alta + las cuotas (el RC real recién se manda al facturar).
class PlanGuardado extends CobranzaFacturaEvent {
  final String fechaVencimiento;
  final List<CuotaPlan> cuotas;
  const PlanGuardado(this.fechaVencimiento, this.cuotas);
}

class FacturarPressed extends CobranzaFacturaEvent {
  const FacturarPressed();
}
