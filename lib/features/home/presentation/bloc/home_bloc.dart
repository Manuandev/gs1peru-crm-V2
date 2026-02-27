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

import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';
import 'package:app_crm/features/home/domain/repositories/i_home_repository.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:app_crm/features/recordatorios/domain/repositories/i_recordatorios_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IHomeRepository _homeRepository;
  final IAuthRepository _authRepository;
  final IRecordatoriosRepository _recordatoriosRepository;

  HomeBloc({
    required IHomeRepository homeRepository,
    required IAuthRepository authRepository,
    required IRecordatoriosRepository recordatoriosRepository,
  }) : _homeRepository = homeRepository,
       _authRepository = authRepository,
       _recordatoriosRepository = recordatoriosRepository,
       super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
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
      // Lanzamos ambas en paralelo
      final leadsF = _homeRepository.listarLeads();
      final recordatoriosF = _recordatoriosRepository.listarRecordatorios();

      // Esperamos ambas de forma independiente
      final leads = await leadsF.catchError((_) => <LeadItem>[]);
      final recordatorios = await recordatoriosF.catchError(
        (_) => <RecordatorioItem>[],
      );

      final user = _authRepository.currentUser!;

      emit(
        HomeLoaded(leads: leads, recordatorios: recordatorios, usuario: user),
      );
    } catch (e, stackTrace) {
      addError(e, stackTrace);

      emit(HomeError(e.toString()));
    }
  }
}
