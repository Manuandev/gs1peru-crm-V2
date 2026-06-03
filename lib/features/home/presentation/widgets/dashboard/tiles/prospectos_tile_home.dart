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
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

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
                    style: themeText.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prospecto.nombreEmpresa.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Empresa: ${prospecto.nombreEmpresa}',
                      style: themeText.labelSmall?.copyWith(
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
              style: themeText.labelSmall?.copyWith(
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

    // Color de fondo suave (10% opacidad) y color del ícono más saturado
    final bgColor = Color.alphaBlend(
      color.withValues(alpha: 0.15),
      Colors.white,
    );
    final iconColor = color;

    return Container(
      width: AppSizing.avatarSm,
      height: AppSizing.avatarSm,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Icon(AppIcons.user, color: iconColor, size: AppSizing.iconMd),
      ),
    );
  }
}
