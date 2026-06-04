// lib/features/auth/presentation/widgets/splash_view.dart
// ============================================================
// SPLASH VIEW
// ============================================================
//
// RESPONSABILIDADES:
// - Mostrar la UI/animación del splash
// - Garantizar un tiempo mínimo de visualización (para la animación)
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
// POR QUÉ StatefulWidget:
// Necesita el timer mínimo (_minTimerDone) y guardar el
// estado pendiente (_pendingState) entre frames.
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

class _SplashViewState extends State<SplashView> {
  /// Controla si el tiempo mínimo de animación ya pasó.
  /// El splash siempre se muestra al menos [_minDuration].
  bool _minTimerDone = false;

  /// Guarda el estado del SplashBloc si llegó antes de que
  /// terminara el timer mínimo.
  SplashState? _pendingState;

  /// Tiempo mínimo que se muestra el splash.
  /// Ajústalo según la duración de tu animación.
  static const Duration _minDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    _startMinTimer();
  }

  /// Inicia el timer mínimo de visualización.
  /// Cuando termina, procesa el estado pendiente si ya llegó.
  void _startMinTimer() {
    Future.delayed(_minDuration, () {
      if (!mounted) return;
      setState(() => _minTimerDone = true);

      // Si el bloc terminó mientras esperábamos el timer, procesarlo ahora
      if (_pendingState != null) {
        _notifyAuthBloc(_pendingState!);
      }
    });
  }

  /// Notifica al AuthBloc según el resultado del SplashBloc.
  /// El AuthBloc cambia su estado y AppWidget navega automáticamente.
  void _notifyAuthBloc(SplashState state) {
    if (!mounted) return;

    if (state is SplashSessionFound) {
      context.read<AuthBloc>().add(
        AuthSessionRestored(userId: state.userId, username: state.username),
      );
    } else if (state is SplashSessionNotFound) {
      // Muestra mensaje si existe (sin internet)
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
                child: esLandscape ? const SplashLandscape() : const SplashPortrait(),
              ),
            );
          },
        ),
      ),
    );
  }
}
