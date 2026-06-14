// lib/features/auth/presentation/widgets/splash/splash_view.dart
// ============================================================
// SPLASH VIEW
// ============================================================
//
// RESPONSABILIDADES:
// - Mostrar la UI/animación del splash
// - Garantizar un tiempo mínimo de visualización (para la animación)
// - Solicitar permisos de notificación sin bloquear el flujo principal
// - Escuchar el resultado del SplashBloc
// - Notificar al AuthBloc (que vive en el root) para que navegue
//
// PATRÓN DE NAVEGACIÓN:
// SplashView NO navega directamente.
//   SplashBloc emite estado
//     → SplashView notifica AuthBloc
//       → AuthBloc cambia estado
//         → AppWidget BlocListener navega
//
// PERMISOS DE NOTIFICACIÓN:
// Se solicitan en segundo plano después del primer frame (hay UI visible).
// El flujo del splash NO espera la respuesta del diálogo — siempre continúa.
// El timeout de 30s garantiza que el diálogo ignorado no bloquee nada.
// ============================================================

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  /// Controla si el tiempo mínimo de animación ya pasó.
  bool _minTimerDone = false;

  /// Guarda el estado del SplashBloc si llegó antes de que terminara el timer.
  SplashState? _pendingState;

  /// Indica que hay un diálogo de permisos en curso.
  /// Se usa en [didChangeAppLifecycleState] para re-verificar al volver.
  bool _solicitandoPermisos = false;

  static const Duration _minDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMinTimer();

    // Los permisos se piden después del primer frame (ya hay UI visible).
    // No bloqueamos initState — el splash se muestra inmediatamente.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _solicitarPermisosEnBackground();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si el usuario volvió al primer plano mientras el diálogo estaba abierto,
    // re-verificamos el permiso. El timeout ya puede haber disparado (ignorado),
    // pero si el usuario aceptó en ese momento, configuramos los listeners ahora.
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
      // Llama init() que detecta el permiso ya concedido y activa los listeners
      // sin mostrar ningún diálogo al usuario
      await FirebaseNotificationService.instance.init();
    }
  }

  // ── Permisos ──────────────────────────────────────────────────

  /// Solicita permisos en background — NO bloquea el flujo del splash.
  /// El splash navega a Login/Home independientemente del resultado aquí.
  Future<void> _solicitarPermisosEnBackground() async {
    final manager = NotificationPermissionManager.instance;
    final debeSolicitar = await manager.deberiaSolicitar();
    if (!debeSolicitar || !mounted) return;

    _solicitandoPermisos = true;

    // timeout = 30s: si el usuario ignora el diálogo más de 30s, avanzamos
    final concedido = await NotificationService.instance.requestPermissions();

    if (!mounted) return;
    _solicitandoPermisos = false;

    if (concedido) {
      await manager.guardarConcedido();
    } else {
      // Distinguir entre denegado explícitamente e ignorado/timeout
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        await manager.guardarDenegado();
      } else {
        // notDetermined o provisional → usuario no respondió (ignorado)
        await manager.guardarIgnorado();
      }
    }
  }

  // ── Timer mínimo ──────────────────────────────────────────────

  void _startMinTimer() {
    Future.delayed(_minDuration, () {
      if (!mounted) return;
      setState(() => _minTimerDone = true);

      if (_pendingState != null) {
        _notifyAuthBloc(_pendingState!);
      }
    });
  }

  // ── Navegación ────────────────────────────────────────────────

  void _notifyAuthBloc(SplashState state) {
    if (!mounted) return;

    if (state is SplashSessionFound) {
      context.read<AuthBloc>().add(
        AuthSessionRestored(userId: state.userId, username: state.username),
      );
    } else if (state is SplashSessionNotFound) {
      if (state.message != null) {
        AppSnackBar.error(context, state.message!);
      }
      context.read<AuthBloc>().add(
        AuthSessionEmpty(
          prefillUsername: state.prefillUsername,
          prefillPassword: state.prefillPassword,
        ),
      );
    } else if (state is SplashError) {
      context.read<AuthBloc>().add(const AuthSessionEmpty());
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listenWhen: (_, current) =>
            current is SplashSessionFound ||
            current is SplashSessionNotFound ||
            current is SplashError,

        listener: (context, state) {
          if (!_minTimerDone) {
            _pendingState = state;
            return;
          }
          _notifyAuthBloc(state);
        },

        child: OrientationBuilder(
          builder: (context, orientation) {
            final esLandscape = orientation == Orientation.landscape;

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                child: esLandscape
                    ? const SplashLandscape()
                    : const SplashPortrait(),
              ),
            );
          },
        ),
      ),
    );
  }
}
