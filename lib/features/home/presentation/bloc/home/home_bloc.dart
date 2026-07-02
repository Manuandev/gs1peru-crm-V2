// lib/features/home/presentation/bloc/home/home_bloc.dart
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

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeUseCase _getData;
  final _session = SessionService();
  late final StreamSubscription<FiltroState> _filtroSub;

  HomeBloc({required GetHomeUseCase getData})
    : _getData = getData,
      super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefresh>(_onRefresh);
    on<HomePrioridadGestionada>(_onPrioridadGestionada);
    // Recarga automática cuando el moderador cambia entre "Mis casos" / "Equipo"
    _filtroSub = FiltroCubit.instance.stream.listen((_) => add(HomeRefresh()));
  }

  @override
  Future<void> close() {
    _filtroSub.cancel();
    return super.close();
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  void _onPrioridadGestionada(
    HomePrioridadGestionada event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is! HomeLoaded) return;
    final prioridades = current.home.prioridades
        .where((p) => p.idNumero != event.idNumero)
        .toList();
    emit(
      HomeLoaded(
        home: current.home.copyWith(prioridades: prioridades),
        usuario: current.usuario,
      ),
    );
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final home = await _getData.call();
      emit(HomeLoaded(home: home, usuario: _session.user!));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(HomeError(e.toString()));
    }
  }
}
