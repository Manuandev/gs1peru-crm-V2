// lib/features/home/presentation/bloc/home_state.dart
// ============================================================
// HOME - ESTADOS
// ============================================================
//
// FLUJO:
// HomeInitial → HomeLoading → HomeLoaded
//                          └→ HomeError (botón reintentar)
// ============================================================

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Lead> leads;
  final List<Reminder> reminders;
  final List<Chat> chats;
  final UserModel usuario;

  const HomeLoaded({
    required this.leads,
    required this.reminders,
    required this.chats,
    required this.usuario,
  });

  @override
  List<Object?> get props => [leads];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
