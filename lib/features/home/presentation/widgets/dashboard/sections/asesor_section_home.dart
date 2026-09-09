// lib/features/home/presentation/widgets/dashboard/sections/asesor_section_home.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

/// Sección "Resumen por asesor" visible para moderadores en vista de equipo.
///
/// Muestra una fila horizontal scrolleable de cards de asesor con:
/// - Avatar con iniciales
/// - Nombre
/// - Estado (En línea / Ausente) con punto de color
/// - Métricas: Activas / Nuevos
class AsesorSectionHome extends StatelessWidget {
  final List<AsesorHome> asesores;

  const AsesorSectionHome({super.key, required this.asesores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Encabezado ───────────────────────────────────────────
        Text(
          'Resumen por asesor',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Lista horizontal o estado vacío ──────────────────────
        if (asesores.isEmpty)
          _EstadoVacioAsesores()
        else
          SizedBox(
            height: _AsesorCard.alturaFija,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: asesores.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) => _AsesorCard(asesor: asesores[i]),
            ),
          ),
      ],
    );
  }
}

// ── Card individual de asesor ─────────────────────────────────────────────────

class _AsesorCard extends StatelessWidget {
  final AsesorHome asesor;

  static const double alturaFija = 120.0;
  static const double anchoFijo = 120.0;

  const _AsesorCard({required this.asesor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorEstado = asesor.enLinea
        ? AppColors.success
        : AppColors.textSecondary;
    final labelEstado = asesor.enLinea ? 'En línea' : 'Ausente';
    final nombreCorto = asesor.nombre.split(' ').take(2).join(' ').aTitulo;

    return Container(
      width: anchoFijo,
      height: alturaFija,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: AppColors.opacityDisabledBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Avatar + nombre + estado ────────────────────────
          Column(
            children: [
              CircleAvatar(
                radius: AppSizing.avatarRadiusXs,
                backgroundColor: asesor.nombre.avatarColor,
                child: Icon(
                  AppIcons.userFilled,
                  color: AppColors.textOnDark,
                  size: AppSizing.avatarXs,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                nombreCorto,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '● ',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorEstado,
                      fontSize: AppTextStyles.sizeXs,
                    ),
                  ),
                  Text(
                    labelEstado,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorEstado,
                      fontSize: AppTextStyles.sizeXs,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Métricas ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Metrica(
                label: 'Activas',
                valor: asesor.activas,
                color: AppColors.info,
              ),
              _Metrica(
                label: 'Nuevos',
                valor: asesor.nuevos,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final int valor;
  final Color color;

  const _Metrica({
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$valor',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: AppTextStyles.weightBold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: AppTextStyles.sizeXs,
          ),
        ),
      ],
    );
  }
}

class _EstadoVacioAsesores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          'Sin asesores disponibles',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
