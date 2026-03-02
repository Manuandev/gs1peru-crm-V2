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

import 'package:app_crm/core/services/session_service.dart';
import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:app_crm/features/chat/domain/repositories/i_chats_repository.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';
import 'package:app_crm/features/home/domain/repositories/i_home_repository.dart';
import 'package:app_crm/features/recordatorio/data/models/recordatorio_model.dart';
import 'package:app_crm/features/recordatorio/domain/repositories/i_recordatorios_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IHomeRepository _homeRepository;
  final IRecordatoriosRepository _recordatoriosRepository;
  final IChatsRepository _chatsRepository;
  final _session = SessionService(); // ✅

  HomeBloc({
    required IHomeRepository homeRepository,
    required IRecordatoriosRepository recordatoriosRepository,
    required IChatsRepository chatsRepository,
  }) : _homeRepository = homeRepository,
       _recordatoriosRepository = recordatoriosRepository,
       _chatsRepository = chatsRepository,
       super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
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

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final results = await Future.wait([
        _safe<List<LeadItem>>(_homeRepository.listarLeads(), []),
        _safe<List<RecordatorioItem>>(
          _recordatoriosRepository.listarRecordatorios(),
          [],
        ),
        _safe<List<ChatItem>>(_chatsRepository.listarChats(), []),
      ]);

      final leads = results[0] as List<LeadItem>;
      final recordatorios = results[1] as List<RecordatorioItem>;
      final chats = results[2] as List<ChatItem>;

      emit(
        HomeLoaded(
          leads: leads,
          recordatorios: recordatorios,
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
