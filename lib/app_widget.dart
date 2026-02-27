// lib/app_widget.dart
// ============================================================
// RAÍZ DE LA APLICACIÓN
// ============================================================
//
// RESPONSABILIDADES:
// - Registrar repositorios globales (RepositoryProvider)
// - Registrar el AuthBloc global (único Bloc que vive aquí)
// - Escuchar AuthBloc para navegar globalmente (Login ↔ Home)
// - Configurar tema y router
//
// PATRÓN:
// AppWidget
//   └── MultiRepositoryProvider   ← repositorios globales
//       └── MultiBlocProvider     ← solo AuthBloc aquí
//           └── BlocListener      ← escucha auth para navegar
//               └── MaterialApp   ← router + tema
//
// IMPORTANTE:
// Solo AuthBloc vive aquí arriba.
// SplashBloc, LoginBloc, HomeBloc se crean en su propia Page.
// ============================================================

import 'package:app_crm/core/presentation/bloc/drawer/drawer_bloc.dart';
import 'package:app_crm/core/presentation/bloc/drawer/drawer_event.dart';
import 'package:app_crm/features/home/data/datasources/remote/home_remote_datasource.dart';
import 'package:app_crm/features/home/data/repositories/home_repository.dart';
import 'package:app_crm/features/home/domain/repositories/i_home_repository.dart';
import 'package:app_crm/features/recordatorios/data/datasources/remote/recordatorios_remote_datasource.dart';
import 'package:app_crm/features/recordatorios/data/repositories/recordatorios_repository.dart';
import 'package:app_crm/features/recordatorios/domain/repositories/i_recordatorios_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:app_crm/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:app_crm/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_crm/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/config/router/app_router.dart';
import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/core/theme/app_theme.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_state.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // ── AUTH REPOSITORY ──────────────────────────────────
        // AuthRemoteDatasource → Dio → API
        // AuthLocalDatasource  → SharedPreferences
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            local: AuthLocalDatasource(),
            remote: AuthRemoteDatasource(),
          ),
        ),

        // ── DRAWER BLOC — global para que los badges funcionen desde cualquier pantalla
        BlocProvider<DrawerBloc>(
          create: (context) =>
              DrawerBloc(authRepository: context.read<IAuthRepository>())
                ..add(DrawerStarted()),
        ),

        // ── HOME REPOSITORY ──────────────────────────────────
        RepositoryProvider<IHomeRepository>(
          create: (context) => HomeRepository(
            remote: HomeRemoteDatasource(
              authRepository: context.read<IAuthRepository>(),
            ),
          ),
        ),

        // ── RECORDATORIOS REPOSITORY ──────────────────────────────────
        RepositoryProvider<IRecordatoriosRepository>(
          create: (context) => RecordatoriosRepository(
            remote: RecordatoriosRemoteDatasource(
              authRepository: context.read<IAuthRepository>(),
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // ── AUTH BLOC — global, vive toda la app ──────────
          // Es el árbitro de la sesión.
          // Cualquier parte de la app puede leerlo con context.read<AuthBloc>()
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              logoutUsecase: LogoutUsecase(context.read<IAuthRepository>()),
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          // Solo reacciona a cambios de autenticación relevantes para navegar
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType &&
              (current is AuthAuthenticated || current is AuthUnauthenticated),

          listener: (context, state) {
            // ── NAVEGACIÓN GLOBAL ──────────────────────────
            // El router limpia el stack completo en ambos casos.
            // Ninguna pantalla necesita saber cómo navegar post-auth.
            if (state is AuthAuthenticated) {
              context.read<DrawerBloc>().add(DrawerStarted());
              context.goToHome();
            } else if (state is AuthUnauthenticated) {
              context.goToLogin();
            }
          },

          child: MaterialApp(
            title: 'GS1 Peru - CRM',
            debugShowCheckedModeBanner: false,

            // ── ROUTER ──────────────────────────────────────
            // NavigatorKey permite navegar sin context (desde servicios, blocs, etc.)
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,

            // ── TEMA ────────────────────────────────────────
            // Todo: personaliza AppTheme.lightTheme y AppTheme.darkTheme
            //       en lib/core/theme/app_theme.dart
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
          ),
        ),
      ),
    );
  }
}
