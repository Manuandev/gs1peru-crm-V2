// lib/features/auth/presentation/widgets/splash/splash_view.dart
// ============================================================
// SPLASH VIEW
// ============================================================
//
// TABLA DE ESTADOS (buildWhen filtra solo los primeros tres):
//
// Estado BLoC              Builder muestra                    Listener hace
// ─────────────────────────────────────────────────────────────────────────
// SplashInitial          → primera slide estática             —
// SplashLoading          → primera slide estática             —
// SplashMostrarOnboarding→ carrusel completo e interactivo    —
// SplashSessionFound     → (sin rebuild)                      AuthSessionRestored → Home
// SplashSessionNotFound  → (sin rebuild)                      goToLogin()
// SplashError            → (sin rebuild)                      goToLogin()
//
// PATRÓN _pendingState:
// El BLoC puede emitir SplashSessionFound/NotFound antes del primer frame.
// _pendingState guarda el estado y addPostFrameCallback lo procesa de forma segura.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  /// Estado de navegación recibido antes del primer frame.
  /// Se procesa en addPostFrameCallback para garantizar que el Navigator esté listo.
  SplashState? _pendingState;

  /// Indica que hay un diálogo de permisos en curso.
  bool _solicitandoPermisos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _solicitarPermisosEnBackground();
      if (_pendingState != null) _procesarEstadoSplash(_pendingState!);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _solicitandoPermisos) {
      _verificarPermisoAlVolver();
    }
  }

  Future<void> _verificarPermisoAlVolver() async {
    if (!mounted) return;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final concedido =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (concedido) {
      await NotificationPermissionManager.instance.guardarConcedido();
      await FirebaseNotificationService.instance.init();
    }
  }

  // ── Permisos ───────────────────────────────────────────────────

  Future<void> _solicitarPermisosEnBackground() async {
    final notifManager = NotificationPermissionManager.instance;
    if (await notifManager.deberiaSolicitar() && mounted) {
      _solicitandoPermisos = true;
      final concedido = await NotificationService.instance.requestPermissions();

      if (!mounted) return;
      _solicitandoPermisos = false;

      if (concedido) {
        await notifManager.guardarConcedido();
      } else {
        final settings =
            await FirebaseMessaging.instance.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          await notifManager.guardarDenegado();
        } else {
          await notifManager.guardarIgnorado();
        }
      }
    }

    if (!mounted) return;

    final locationManager = LocationPermissionManager.instance;
    if (await locationManager.deberiaSolicitar()) {
      await _solicitarPermisoUbicacion(locationManager);
    }
  }

  Future<void> _solicitarPermisoUbicacion(
    LocationPermissionManager manager,
  ) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await manager.guardarConcedido();
      } else if (permission == LocationPermission.deniedForever) {
        await manager.guardarDenegadoPermanente();
      } else {
        await manager.guardarDenegado();
      }
    } catch (_) {
      // Error de GPS — no bloquea el flujo
    }
  }

  // ── Navegación al completar el onboarding ──────────────────────

  /// Llamado por OnboardingCarousel cuando el usuario pulsa "Finalizar".
  /// Guarda el flag en SQLite y navega a Login.
  void _alFinalizarOnboarding() {
    unawaited(_guardarFlagYNavegar());
  }

  Future<void> _guardarFlagYNavegar() async {
    await LocalDatabase().setSetting('onboarding_completado', 'true');
    if (!mounted) return;
    context.goToLogin();
  }

  // ── Procesamiento de estados de navegación ─────────────────────

  void _procesarEstadoSplash(SplashState estado) {
    if (!mounted) return;

    if (estado is SplashSessionFound) {
      context.read<AuthBloc>().add(
        AuthSessionRestored(
          userId: estado.userId,
          username: estado.username,
        ),
      );
    } else if (estado is SplashSessionNotFound) {
      if (estado.message != null) {
        AppSnackBar.error(context, estado.message!);
      }
      context.goToLogin();
    } else if (estado is SplashError) {
      context.goToLogin();
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      // Solo dispara la navegación — el builder no se toca con estos estados
      listenWhen: (_, current) =>
          current is SplashSessionFound ||
          current is SplashSessionNotFound ||
          current is SplashError,

      listener: (context, state) {
        if (!mounted) return;
        _pendingState = state;
        _procesarEstadoSplash(state);
      },

      // Solo los tres estados que cambian la UI del splash
      buildWhen: (_, current) =>
          current is SplashInitial ||
          current is SplashLoading ||
          current is SplashMostrarOnboarding,

      builder: (context, state) {
        if (state is SplashMostrarOnboarding) {
          return OnboardingCarousel(
            alEmpezar: _alFinalizarOnboarding,
            soloMostrarPrimeraSlide: false,
          );
        }
        // SplashInitial / SplashLoading → primera slide estática sin controles
        return const OnboardingCarousel(soloMostrarPrimeraSlide: true);
      },
    );
  }
}
