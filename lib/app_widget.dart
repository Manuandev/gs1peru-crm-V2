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

// DEPENDENCIAS
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/index_core.dart';
import 'features/chat/index_chat.dart';
import 'features/reminder/index_reminder.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class AppWidget extends StatelessWidget {
  final ThemeCubit themeCubit; // ✅ nuevo

  const AppWidget({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // ── AUTH REPOSITORY ──────────────────────────────────
        // AuthRemoteDatasource → Dio → API
        // AuthLocalDatasource  → SharedPreferences
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            local: AuthLocalDatasource(),
            remote: AuthRemoteDatasource(),
          ),
        ),

        // ── HOME REPOSITORY ──────────────────────────────────
        RepositoryProvider<LeadRepository>(
          create: (context) => LeadRepositoryImpl(LeadRemoteDatasource()),
        ),

        // ── REMINDERS REPOSITORY ──────────────────────────────────
        RepositoryProvider<ReminderRepository>(
          create: (context) =>
              ReminderRepositoryImpl(ReminderRemoteDatasource()),
        ),

        // ── CHATS REPOSITORY ──────────────────────────────────
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(ChatRemoteDatasource()),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          // ── AUTH BLOC — global, vive toda la app ──────────
          // Es el árbitro de la sesión.
          // Cualquier parte de la app puede leerlo con context.read<AuthBloc>()
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              logoutUsecase: LogoutUsecase(context.read<AuthRepository>()),
            ),
          ), // ✅ DrawerBloc va aquí
          BlocProvider<DrawerBloc>(
            create: (context) => DrawerBloc()..add(DrawerStarted()),
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

          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
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
                // themeMode: ThemeMode.system,
                themeMode: themeMode, // ✅ ahora es dinámico
              );
            },
          ),
        ),
      ),
    );
  }
}
