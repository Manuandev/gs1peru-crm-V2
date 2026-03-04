// lib/features/home/presentation/bloc/home_bloc.dart
// ============================================================
// HOME BLOC
// ============================================================
//
// RESPONSABILIDAD ÚNICA:
// Cargar y refrescar los datos del Home (perfil, badges, etc.)
//
// VIVE EN:
// HomePage (local) → se destruye cuando el Home desaparece
//
// FLUJO:
// 1. HomePage dispara HomeStarted al crearse
// 2. HomeBloc carga datos del usuario desde BD o API
// 3. Emite HomeLoaded con los datos
//
// NO HACE:
// - No maneja logout (eso es AuthBloc desde el Drawer)
// - No valida sesión (eso ya lo hizo SplashBloc/LoginBloc)
// - No navega
//
// REGLA:
// Si llegaste al Home, ya estás autenticado.
// El HomeBloc solo carga datos de negocio.
//
// DEPENDENCIAS:
// - IAuthRepository → (opcional) para leer datos del usuario desde BD
// - IHomeRepository → (cuando exista) para cargar datos del home
// ============================================================


import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetLeadsUseCase _getLeads;
  final GetRemindersUseCase _getReminders;
  final GetChatsUseCase _getChats;
  final _session = SessionService();

  HomeBloc({
    required GetLeadsUseCase getLeads,
    required GetRemindersUseCase getReminders,
    required GetChatsUseCase getChats,
  }) : _getLeads = getLeads,
       _getReminders = getReminders,
       _getChats = getChats,
       super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefresh>(_onRefresh);
  }

  // ✅ Helper tipado explícito — evita el bug de inferencia de catchError
  Future<T> _safe<T>(Future<T> future, T fallback) async {
    try {
      return await future;
    } catch (e) {
      // Puedes loggear aquí si quieres: debugPrint('_safe error: $e');
      return fallback;
    }
  }

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    HomeRefresh event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final results = await Future.wait([
        _safe<List<Lead>>(_getLeads(), []),
        _safe<List<Reminder>>(_getReminders(), []),
        _safe<List<Chat>>(_getChats(), []),
      ]);

      final leads = results[0] as List<Lead>;
      final reminders = results[1] as List<Reminder>;
      final chats = results[2] as List<Chat>;

      emit(
        HomeLoaded(
          leads: leads,
          reminders: reminders,
          chats: chats,
          usuario: _session.user!,
        ),
      );
    } catch (e, stackTrace) {
      // Solo llega aquí si _session.user! es null u otro error crítico
      addError(e, stackTrace);
      emit(HomeError(e.toString()));
    }
  }
}
