// lib/features/home/presentation/bloc/home_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

/// La pantalla se inicializó.
/// Carga los datos del usuario (nombre, email, badges).
/// Disparado automáticamente por HomePage al crearse.
class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

/// El usuario pidió actualizar los datos.
/// Disparado por: popup "Actualizar" o pull-to-refresh.
/// No muestra spinner completo para no parpadear la UI.
class ChatListRefreshed extends ChatListEvent {
  const ChatListRefreshed();
}

class ChatListSearched extends ChatListEvent {
  final String query;
  const ChatListSearched(this.query);
}