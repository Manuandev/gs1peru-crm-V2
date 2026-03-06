// lib/features/auth/presentation/pages/splash_page.dart
// ============================================================
// SPLASH PAGE
// ============================================================
//
// RESPONSABILIDADES:
// - Crear el SplashBloc con sus dependencias
// - Disparar SplashCheckSessionRequested al iniciar
//
// NO HACE:
// - UI            → SplashView
// - Navegación    → SplashView notifica al AuthBloc, AppWidget navega
// - Lógica sesión → SplashBloc
//
// ESTRUCTURA:
// SplashPage
//   └── BlocProvider<SplashBloc>
//         └── SplashView
// ============================================================

import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        restoreSessionUsecase: RestoreSessionUsecase(context.read<AuthRepository>()),
      )..add(const SplashCheckSessionRequested()),
      child: const SplashView(),
    );
  }
}
