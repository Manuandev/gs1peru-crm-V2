// lib/features/auth/presentation/pages/recuperar_clave_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_crm/features/auth/domain/usecases/recuperar_clave_usecase.dart';
import 'package:app_crm/features/auth/presentation/bloc/recuperar_clave/recuperar_clave_cubit.dart';
import 'package:app_crm/features/auth/presentation/widgets/recuperar_clave/recuperar_clave_view.dart';

class RecuperarClavePage extends StatelessWidget {
  const RecuperarClavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecuperarClaveCubit(
        RecuperarClaveUseCase(context.read<AuthRepository>()),
      ),
      child: const RecuperarClaveView(),
    );
  }
}
