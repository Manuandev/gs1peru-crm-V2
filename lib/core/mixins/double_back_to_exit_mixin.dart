// lib/core/mixins/double_back_to_exit_mixin.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin DoubleBackToExitMixin<T extends StatefulWidget> on State<T> {
  DateTime? _lastBackPress;

  Future<bool> onWillPop() async {
    final now = DateTime.now();
    final isSecondPress = _lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2);

    if (isSecondPress) {
      // Segunda vez → salir
      await SystemNavigator.pop();
      return true;
    }

    // Primera vez → aviso
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.white),
            SizedBox(width: 12),
            Text('Presiona nuevamente para salir'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return false;
  }
}