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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/auth/presentation/bloc/splash/splash_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/splash/splash_event.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/splash_view.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        // IAuthRepository viene del RepositoryProvider registrado en AppWidget
        authRepository: context.read<IAuthRepository>(),
      )..add(const SplashCheckSessionRequested()),
      child: const SplashView(),
    );
  }
}
