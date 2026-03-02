// lib/features/home/presentation/bloc/home_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class RecordatoriosEvent extends Equatable {
  const RecordatoriosEvent();

  @override
  List<Object?> get props => [];
}

/// La pantalla se inicializó.
/// Carga los datos del usuario (nombre, email, badges).
/// Disparado automáticamente por HomePage al crearse.
class RecordatoriosStarted extends RecordatoriosEvent {
  const RecordatoriosStarted();
}

/// El usuario pidió actualizar los datos.
/// Disparado por: popup "Actualizar" o pull-to-refresh.
/// No muestra spinner completo para no parpadear la UI.
class RecordatoriosRefreshRequested extends RecordatoriosEvent {
  const RecordatoriosRefreshRequested();
}
