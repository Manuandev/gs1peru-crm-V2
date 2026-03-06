// lib\core\widgets\app_empty_view.dart

import 'package:flutter/material.dart';

class AppEmptyView extends StatelessWidget {
  final String message;
  const AppEmptyView({super.key, this.message = 'No hay datos disponibles.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.grey.shade500)),
    );
  }
}
