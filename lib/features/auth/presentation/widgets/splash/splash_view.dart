// lib/features/auth/presentation/widgets/splash/splash_view.dart
// ============================================================
// SPLASH VIEW
// ============================================================
//
// PATRÓN DE NAVEGACIÓN:
//   SplashBloc emite SplashSessionFound
//     → SplashView guarda userId/username, NO navega aún
//     → El usuario recorre el carrusel y toca "Empezar"
//       → _alEmpezar() dispara AuthSessionRestored
//         → AppWidget BlocListener llama context.goToHome()
//
//   SplashBloc emite SplashSessionNotFound
//     → SplashView muestra error si existe
//     → El usuario toca "Empezar"
//       → _alEmpezar() llama context.goToLogin()
// ============================================================

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_carousel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  /// Estado del SplashBloc recibido antes del primer frame.
  SplashState? _pendingState;

  /// Indica que hay un diálogo de permisos en curso.
  bool _solicitandoPermisos = false;

  /// Datos de sesión guardados cuando SplashBloc responde SessionFound.
  /// Solo se usan cuando el usuario pulsa "Empezar" en el último slide.
  String? _sessionUserId;
  String? _sessionUsername;

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

  // ── Estado del SplashBloc ──────────────────────────────────────

  void _procesarEstadoSplash(SplashState state) {
    if (!mounted) return;

    if (state is SplashSessionFound) {
      // Guardamos los datos de sesión, pero NO navegamos todavía.
      // La navegación ocurre cuando el usuario pulsa "Empezar".
      setState(() {
        _sessionUserId = state.userId;
        _sessionUsername = state.username;
      });
    } else if (state is SplashSessionNotFound) {
      if (state.message != null) {
        final mensaje = state.message!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) AppSnackBar.error(context, mensaje);
        });
      }
    }
    // SplashError: el carrusel se muestra igualmente
  }

  // ── Callback para "Empezar" ────────────────────────────────────

  void _alEmpezar() {
    if (!mounted) return;
    if (_sessionUserId != null && _sessionUsername != null) {
      // Hay sesión: restaurarla en AuthBloc → AppWidget navega a Home
      context.read<AuthBloc>().add(
        AuthSessionRestored(
          userId: _sessionUserId!,
          username: _sessionUsername!,
        ),
      );
    } else {
      // Sin sesión: ir a Login
      context.goToLogin();
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listenWhen: (_, current) =>
          current is SplashSessionFound ||
          current is SplashSessionNotFound ||
          current is SplashError,

      listener: (context, state) {
        if (!mounted) return;
        _pendingState = state;
        _procesarEstadoSplash(state);
      },

      child: OnboardingCarousel(alEmpezar: _alEmpezar),
    );
  }
}
