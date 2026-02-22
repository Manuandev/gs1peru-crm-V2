// lib/features/auth/presentation/pages/login_page.dart
// ============================================================
// LOGIN PAGE
// ============================================================
//
// RESPONSABILIDADES:
// - Crear LoginBloc con sus dependencias
// - Proveerlo a la sub-árbol (LoginView)
//
// NO HACE:
// - UI          → LoginView
// - Validación  → LoginBloc
// - Navegación  → LoginView notifica AuthBloc, AppWidget navega
//
// ESTRUCTURA:
// LoginPage
//   └── BlocProvider<LoginBloc>
//         └── LoginView (StatefulWidget)
//               ├── LoginFormController (ciclo de vida)
//               ├── BlocConsumer<LoginBloc>
//               │     ├── listener → notifica AuthBloc si LoginSuccess
//               │     └── builder  → UI según estado
//               └── OrientationBuilder
//                     ├── LoginPortraitCard
//                     └── LoginLandscapeCard
// ============================================================

import 'package:flutter/material.dart';
import 'package:app_crm/features/auth/presentation/widgets/login/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/auth/presentation/bloc/login/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        // IAuthRepository viene del RepositoryProvider registrado en AppWidget
        authRepository: context.read<IAuthRepository>(),
      ),
      child: const LoginView(),
    );
  }
}
