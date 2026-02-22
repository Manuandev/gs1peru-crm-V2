// lib/features/auth/presentation/bloc/auth/auth_bloc.dart
// ============================================================
// AUTH BLOC — GLOBAL
// ============================================================
//
// RESPONSABILIDAD ÚNICA:
// Ser el árbitro de la sesión en toda la app.
// Sabe si el usuario está autenticado o no.
//
// VIVE EN:
// AppWidget (root) → disponible en todo el árbol con context.read<AuthBloc>()
//
// QUIÉN LO USA:
// - SplashView    → dispara AuthSessionRestored / AuthSessionEmpty
// - LoginView     → dispara AuthLoginSuccess
// - AppDrawer     → dispara AuthLogoutRequested
// - AppWidget     → escucha estados para navegar
//
// NO HACE:
// - No navega (eso lo hace AppWidget via BlocListener)
// - No muestra UI (eso lo hace cada View)
// - No valida credenciales (eso lo hace LoginBloc)
// - No verifica sesión local (eso lo hace SplashBloc)
//
// DEPENDENCIAS:
// - LogoutUsecase → limpia la sesión al hacer logout
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogoutUsecase _logoutUsecase;

  AuthBloc({required LogoutUsecase logoutUsecase})
    : _logoutUsecase = logoutUsecase,
      super(const AuthInitial()) {
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthSessionEmpty>(_onSessionEmpty);
    on<AuthLoginSuccess>(_onLoginSuccess);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // ── MANEJADORES ─────────────────────────────────────────────

  /// Splash encontró sesión válida → marcar como autenticado
  void _onSessionRestored(AuthSessionRestored event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(userId: event.userId, username: event.username));
  }

  /// Splash no encontró sesión → marcar como no autenticado
  void _onSessionEmpty(AuthSessionEmpty event, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }

  /// Login exitoso → marcar como autenticado
  void _onLoginSuccess(AuthLoginSuccess event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(userId: event.userId, username: event.username));
  }

  /// Logout solicitado → limpiar sesión → marcar como no autenticado
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // ── LIMPIAR SESIÓN ─────────────────────────────────────
    // LogoutUsecase → IAuthRepository.logout()
    // → AuthLocalDatasource.clearSession()  (limpia SQLite/SharedPrefs)
    // → AuthRemoteDatasource.logout()       (invalida token en API, si aplica)
    await _logoutUsecase();

    emit(const AuthUnauthenticated());
  }
}
