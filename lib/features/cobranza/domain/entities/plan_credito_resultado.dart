// lib/features/cobranza/domain/entities/plan_credito_resultado.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

// Lo que CobranzaPlanPage devuelve al hacer pop tras "Guardar plan" — el
// RC real (guardar en el backend) recién se dispara cuando el usuario
// presiona "Facturar" en CobranzaFacturaPage, no acá (ver cobranza/CLAUDE.md).
class PlanCreditoResultado {
  final String fechaVencimiento;
  final List<CuotaPlan> cuotas;

  const PlanCreditoResultado({
    required this.fechaVencimiento,
    required this.cuotas,
  });
}
