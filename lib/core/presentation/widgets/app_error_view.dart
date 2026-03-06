// lib\core\errors\app_error_view.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorIconSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 64,
      tablet: 72,
      desktop: 80,
    );
    final errorTextSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: errorIconSize,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: errorTextSize,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}