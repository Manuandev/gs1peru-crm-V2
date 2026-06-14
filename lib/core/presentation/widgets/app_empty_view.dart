// lib/core/presentation/widgets/app_empty_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class AppEmptyView extends StatelessWidget {
  final String message;
  const AppEmptyView({super.key, this.message = 'No hay datos disponibles.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
      ),
    );
  }
}
