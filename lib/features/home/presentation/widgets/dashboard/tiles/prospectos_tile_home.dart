// lib/features/home/presentation/widgets/dashboard/tiles/prospectos_tile_home.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class ProspectoTileHome extends StatelessWidget {
  final ProspectoHome prospecto;
  const ProspectoTileHome({super.key, required this.prospecto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

    final titleStyle = themeText.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: themeText.titleSmall!.color,
    );

    final empresaStyle = themeText.labelSmall?.copyWith(
      color: AppColors.textSecondary,
    );

    final fechaStyle = themeText.labelSmall?.copyWith(
      color: AppColors.textSecondary,
    );

    final avatarStyle = themeText.labelMedium?.copyWith(
      color: AppColors.textOnDark,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSizing.avatarRadiusSm,
                backgroundColor: prospecto.nombre.avatarColor,
                child: Text(prospecto.nombre.initials, style: avatarStyle),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prospecto.nombre,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (prospecto.nombreEmpresa.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Empresa: ${prospecto.nombreEmpresa}',
                        style: empresaStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(prospecto.fechaHora.formatConDia(), style: fechaStyle),
            ],
          ),
        ],
      ),
    );
  }
}
