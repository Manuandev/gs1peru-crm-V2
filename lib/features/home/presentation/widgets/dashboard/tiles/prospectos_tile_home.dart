// lib/features/home/presentation/widgets/dashboard/tiles/prospectos_tile_home.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class ProspectoTileHome extends StatelessWidget {
  final ProspectoHome prospecto;
  final VoidCallback? onTap;

  const ProspectoTileHome({super.key, required this.prospecto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // ── AVATAR con ícono ──────────────────────────────────
            _Avatar(nombre: prospecto.nombre),
            const SizedBox(width: AppSpacing.md),

            // ── NOMBRE + EMPRESA ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prospecto.nombre,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prospecto.nombreEmpresa.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Empresa: ${prospecto.nombreEmpresa}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // ── FECHA ─────────────────────────────────────────────
            Text(
              prospecto.fechaHora.formatConDia(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // ── FLECHA ────────────────────────────────────────────
            Icon(
              AppIcons.forward,
              size: AppSizing.iconActionSm,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar: círculo con color por nombre + ícono de persona ────────
class _Avatar extends StatelessWidget {
  final String nombre;

  const _Avatar({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final color = nombre.avatarColor;

    final bgColor = Color.alphaBlend(
      color.withValues(alpha: AppColors.opacityAvatarBg),
      AppColors.surface,
    );

    return Container(
      width: AppSizing.avatarSm,
      height: AppSizing.avatarSm,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Icon(AppIcons.user, color: color, size: AppSizing.iconMd),
      ),
    );
  }
}
