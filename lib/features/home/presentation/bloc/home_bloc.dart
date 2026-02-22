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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // ── DEPENDENCIAS ─────────────────────────────────────────
  // Todo: agrega tus repositorios cuando estén listos
  // final IHomeRepository _homeRepository;

  HomeBloc() : super(const HomeInitial()) {
    // Todo: con dependencias sería:
    // HomeBloc({required IHomeRepository homeRepository})
    //     : _homeRepository = homeRepository,
    //       super(const HomeInitial()) {

    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
  }

  // ── MANEJADORES ─────────────────────────────────────────────

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      await _loadData(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(HomeError('Error al cargar: ${e.toString()}'));
    }
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // No emite HomeLoading para no hacer parpadear la UI al refrescar
    // Si quieres un indicador sutil de refresh, puedes agregar
    // un estado HomeRefreshing que la UI muestre diferente a HomeLoading
    try {
      await _loadData(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(HomeError('Error al refrescar: ${e.toString()}'));
    }
  }

  /// Carga los datos del Home desde BD o API.
  /// Método privado compartido entre HomeStarted y HomeRefreshRequested.
  Future<void> _loadData(Emitter<HomeState> emit) async {
    // ── OPCIÓN A: CARGAR DESDE SQLITE ──────────────────────
    // Todo: descomentar cuando tengas tu BD implementada
    /*
    final session = await _homeRepository.getSession();
    final results = await Future.wait([
      _homeRepository.getUnreadChatsCount(),
      _homeRepository.getPendingRecordatoriosCount(),
      _homeRepository.getNewLeadsCount(),
    ]);

    emit(HomeLoaded(
      userName: session.username,
      userSubtitle: session.email,
      unreadChats: results[0],
      pendingRecordatorios: results[1],
      newLeads: results[2],
    ));
    */

    // ── OPCIÓN B: CARGAR DESDE API ──────────────────────────
    // Todo: descomentar cuando tengas tu API implementada
    /*
    final data = await _homeRepository.getHomeData();
    emit(HomeLoaded(
      userName: data.userName,
      userSubtitle: data.email,
      userAvatarUrl: data.avatarUrl,
      unreadChats: data.unreadChats,
      pendingRecordatorios: data.pendingRecordatorios,
      newLeads: data.newLeads,
    ));
    */

    // ── MOCK TEMPORAL ───────────────────────────────────────
    // Todo: eliminar cuando implementes OPCIÓN A o OPCIÓN B
    await Future.delayed(const Duration(milliseconds: 300));

    emit(const HomeLoaded(
      userName: 'Admin',
      userSubtitle: 'admin@empresa.com',
      unreadChats: 3,
      pendingRecordatorios: 1,
      newLeads: 0,
    ));
  }
}