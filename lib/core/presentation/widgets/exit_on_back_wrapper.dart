// lib/core/presentation/widgets/exit_on_back_wrapper.dart

import 'package:flutter/material.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';

class ExitOnBackWrapper extends StatelessWidget {
  final Widget child;
  const ExitOnBackWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final confirmed = await context.showConfirmDialog(
          title: 'Salir',
          message: '¿Deseas salir de la aplicación?',
          confirmText: 'Salir',
          cancelText: 'Cancelar',
        );

        if (confirmed) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}