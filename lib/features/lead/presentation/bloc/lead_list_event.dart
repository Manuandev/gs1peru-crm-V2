// lib\features\reminder\presentation\bloc\reminder_list_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class LeadListEvent extends Equatable {
  const LeadListEvent();

  @override
  List<Object?> get props => [];
}

/// La pantalla se inicializó.
/// Carga los datos del usuario (nombre, email, badges).
/// Disparado automáticamente por HomePage al crearse.
class LeadListStarted extends LeadListEvent {
  const LeadListStarted();
}

/// El usuario pidió actualizar los datos.
/// Disparado por: popup "Actualizar" o pull-to-refresh.
/// No muestra spinner completo para no parpadear la UI.
class LeadListRefresh extends LeadListEvent {
  const LeadListRefresh();
}
