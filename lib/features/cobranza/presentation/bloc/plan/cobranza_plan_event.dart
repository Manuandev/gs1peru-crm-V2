// lib/features/cobranza/presentation/bloc/plan/cobranza_plan_event.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaPlanEvent {
  const CobranzaPlanEvent();
}

class CobranzaPlanStarted extends CobranzaPlanEvent {
  const CobranzaPlanStarted();
}

// "¿En cuántas cuotas?" (resumen) — solo actualiza el número deseado; la
// generación real de cuotas ocurre al presionar "Vista previa".
class NumCuotasDeseadasChanged extends CobranzaPlanEvent {
  final int valor;
  const NumCuotasDeseadasChanged(this.valor);
}

// Genera el cronograma completo: numCuotasDeseadas cuotas, monto = importe
// comprobante / N cada una, días por defecto 7*i (i=1..N).
class VistaPreviaPressed extends CobranzaPlanEvent {
  const VistaPreviaPressed();
}

// Limpia todo el cronograma (no solo el formulario).
class LimpiarPressed extends CobranzaPlanEvent {
  const LimpiarPressed();
}

// Tap en una fila del cronograma — carga esa cuota en "Configurar cuota".
class CuotaSeleccionada extends CobranzaPlanEvent {
  final CuotaPlan cuota;
  const CuotaSeleccionada(this.cuota);
}

class DiasChanged extends CobranzaPlanEvent {
  final int dias;
  const DiasChanged(this.dias);
}

class FechaCuotaChanged extends CobranzaPlanEvent {
  final String fecha;
  const FechaCuotaChanged(this.fecha);
}

// Aplica Días/Fecha del formulario a la cuota seleccionada (formNumeroCuota).
class ModificarCuotaPressed extends CobranzaPlanEvent {
  const ModificarCuotaPressed();
}

class GuardarPlanPressed extends CobranzaPlanEvent {
  const GuardarPlanPressed();
}
