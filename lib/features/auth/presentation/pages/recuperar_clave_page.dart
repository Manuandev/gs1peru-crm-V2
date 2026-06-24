// lib/features/auth/presentation/pages/recuperar_clave_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class RecuperarClavePage extends StatelessWidget {
  const RecuperarClavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecuperarClaveBloc(
        RecuperarClaveUseCase(context.read<AuthRepository>()),
      ),
      child: const RecuperarClaveView(),
    );
  }
}
