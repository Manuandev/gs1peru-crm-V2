// lib/features/home/presentation/bloc/home_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

/// La pantalla se inicializó.
/// Carga los datos del usuario (nombre, email, badges).
/// Disparado automáticamente por HomePage al crearse.
class ChatsStarted extends ChatsEvent {
  const ChatsStarted();
}

/// El usuario pidió actualizar los datos.
/// Disparado por: popup "Actualizar" o pull-to-refresh.
/// No muestra spinner completo para no parpadear la UI.
class ChatsRefreshRequested extends ChatsEvent {
  const ChatsRefreshRequested();
}
