// lib/features/cobranza/presentation/bloc/cobranza_plan_event.dart

abstract class CobranzaPlanEvent {
  const CobranzaPlanEvent();
}

class CobranzaPlanStarted extends CobranzaPlanEvent {
  const CobranzaPlanStarted();
}

class NumeroCuotaChanged extends CobranzaPlanEvent {
  final int valor;
  const NumeroCuotaChanged(this.valor);
}

class DiasChanged extends CobranzaPlanEvent {
  final int dias;
  const DiasChanged(this.dias);
}

class FechaCuotaChanged extends CobranzaPlanEvent {
  final String fecha;
  const FechaCuotaChanged(this.fecha);
}

class MontoCuotaChanged extends CobranzaPlanEvent {
  final double monto;
  const MontoCuotaChanged(this.monto);
}

class VistaPreviaPressed extends CobranzaPlanEvent {
  const VistaPreviaPressed();
}

class LimpiarPressed extends CobranzaPlanEvent {
  const LimpiarPressed();
}

class GuardarPlanPressed extends CobranzaPlanEvent {
  const GuardarPlanPressed();
}
