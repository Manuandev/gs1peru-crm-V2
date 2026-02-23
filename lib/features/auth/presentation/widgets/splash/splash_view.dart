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

import 'package:app_crm/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/splash_landscape.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/splash_portrait.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:app_crm/features/auth/presentation/bloc/splash/splash_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/splash/splash_state.dart';

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
  static const Duration _minDuration = Duration(seconds: 2);

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
        context.showErrorSnack(state.message!);
      }
      context.read<AuthBloc>().add(const AuthSessionEmpty());
    } else if (state is SplashError) {
      context.read<AuthBloc>().add(const AuthSessionEmpty());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        // Solo escucha estados finales (no SplashInitial ni SplashLoading)
        listenWhen: (_, current) =>
            current is SplashSessionFound ||
            current is SplashSessionNotFound ||
            current is SplashError,

        listener: (context, state) {
          if (!_minTimerDone) {
            // Timer aún no terminó → guardar para procesar después
            _pendingState = state;
            return;
          }
          // Timer ya terminó → notificar inmediatamente
          _notifyAuthBloc(state);
        },

        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: ResponsiveHelper.screenPadding(context),
                  child: isLandscape
                      // ── HORIZONTAL ──────────────────────────────────
                      // Todo: implementa splashOrientationWidth
                      ? SplashLandscape()
                      // ── VERTICAL ────────────────────────────────────
                      // Todo: implementa splashOrientationHeigt
                      : SplashPortrait(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
