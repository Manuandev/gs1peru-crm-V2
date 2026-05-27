// lib/features/home/presentation/widgets/exit_on_back_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator

import 'package:app_crm/config/index_config.dart';

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

        if (confirmed == true) {
          // ✅ Cierra la app de verdad — sin pantalla negra
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
