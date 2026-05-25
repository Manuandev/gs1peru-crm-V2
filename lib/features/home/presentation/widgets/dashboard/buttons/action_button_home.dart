// lib\features\home\presentation\widgets\dashboard\botones\action_button_home.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip; // el texto que sale al mantener presionado

  const ActionButtonWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ), // ajusta según tu layout
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          onTap: onTap,
          child: Container(
            width: AppSizing.buttonHeightSmall,
            height: AppSizing.buttonHeightSmall,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppSizing.iconActionSm,
            ),
          ),
        ),
      ),
    );
  }
}
