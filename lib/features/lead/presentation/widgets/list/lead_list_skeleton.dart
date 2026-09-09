// lib/features/lead/presentation/widgets/list/lead_list_skeleton.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Skeleton COMPLETO de Seguimiento — espeja `SeguimientoPortrait`:
/// fila de chips + fila de contadores (3 tarjetas) + lista de cards.
/// Solo se usa en la PRIMERA carga (`SeguimientoCargando`). El cambio de chip /
/// aplicar filtro reusa solo [LeadCardSkeletonList] dejando chips y contadores
/// reales montados.
class LeadListSkeleton extends StatelessWidget {
  const LeadListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ChipsSkeleton(),
        SizedBox(height: AppSpacing.xs),
        _StatsSkeleton(),
        SizedBox(height: AppSpacing.sm),
        Expanded(child: LeadCardSkeletonList()),
      ],
    );
  }
}

/// Solo la lista de cards placeholder — para la recarga parcial (cambio de chip
/// / filtro) sin tocar chips ni contadores.
class LeadCardSkeletonList extends StatelessWidget {
  const LeadCardSkeletonList({super.key, this.cantidad = 7});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: cantidad,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: _LeadCardSkeleton(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de filtro — mismos padding/scroll que LeadListFilterChips (4 chips).
// ─────────────────────────────────────────────────────────────────────────────

class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthSm),
            SizedBox(width: AppSpacing.sm),
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthSm),
            SizedBox(width: AppSpacing.sm),
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthMd),
            SizedBox(width: AppSpacing.sm),
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthMd),
          ],
        ),
      ),
    );
  }
}

class _ChipSkeleton extends StatelessWidget {
  final double ancho;

  const _ChipSkeleton({required this.ancho});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: ancho,
      height: AppSizing.skeletonChipHeight,
      borderRadius: AppSizing.radiusXl,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de contadores — espeja LeadListStatsRow (3 tarjetas Expanded).
// ─────────────────────────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: _StatCardSkeleton()),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCardSkeleton()),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCardSkeleton()),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SkeletonBox(
            width: AppSizing.avatarXs,
            height: AppSizing.avatarXs,
            borderRadius: AppSizing.radiusCircular,
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(
                  width: AppSizing.infoLabelWidth,
                  height: AppSizing.skeletonLineHeight,
                ),
                SizedBox(height: AppSpacing.xxs),
                SkeletonBox(
                  width: AppSizing.skeletonChipWidthSm,
                  height: AppSizing.skeletonLineHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de lead — espeja el layout de LeadCard.
// ─────────────────────────────────────────────────────────────────────────────

class _LeadCardSkeleton extends StatelessWidget {
  const _LeadCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurXs,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: AppSizing.avatarSm,
                height: AppSizing.avatarSm,
                borderRadius: AppSizing.radiusCircular,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(child: _InfoSkeleton()),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          _AccionesSkeleton(),
        ],
      ),
    );
  }
}

class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: AppSizing.skeletonNameWidth,
          height: AppSizing.skeletonLineHeight,
        ),
        SizedBox(height: AppSpacing.xxs),
        SkeletonBox(
          width: AppSizing.skeletonTextWidth,
          height: AppSizing.skeletonLineHeight,
        ),
        SizedBox(height: AppSpacing.xxs),
        SkeletonBox(
          width: AppSizing.infoLabelWidth,
          height: AppSizing.skeletonLineHeight,
        ),
      ],
    );
  }
}

class _AccionesSkeleton extends StatelessWidget {
  const _AccionesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(
          width: AppSizing.miniActionButtonSm,
          height: AppSizing.miniActionButtonSm,
          borderRadius: AppSizing.radiusSm,
        ),
        SizedBox(width: AppSpacing.xs),
        SkeletonBox(
          width: AppSizing.skeletonChipWidthSm,
          height: AppSizing.miniActionButtonSm,
          borderRadius: AppSizing.radiusSm,
        ),
      ],
    );
  }
}
