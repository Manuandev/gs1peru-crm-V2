// lib/features/solicitudes/presentation/widgets/list/solicitud_list_skeleton.dart
//
// Skeleton COMPLETO de Solicitudes — fila de indicadores + chips + cards.
// Solo en la primera carga (SolicitudListLoading). El cambio de chip / filtro
// reusa solo [SolicitudCardSkeletonList] dejando chips e indicadores reales.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class SolicitudListSkeleton extends StatelessWidget {
  const SolicitudListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _IndicadoresSkeleton(),
        _ChipsSkeleton(),
        SizedBox(height: AppSpacing.xs),
        Expanded(child: SolicitudCardSkeletonList()),
      ],
    );
  }
}

/// Solo la lista de cards placeholder — para la recarga parcial.
class SolicitudCardSkeletonList extends StatelessWidget {
  const SolicitudCardSkeletonList({super.key, this.cantidad = 5});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: cantidad,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: _SolicitudCardSkeleton(),
      ),
    );
  }
}

// ─── Indicadores (2 tarjetas, espeja _IndicadoresRow) ─────────────────────────

class _IndicadoresSkeleton extends StatelessWidget {
  const _IndicadoresSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: _IndicadorItemSkeleton()),
          _VDivider(),
          Expanded(child: _IndicadorItemSkeleton()),
        ],
      ),
    );
  }
}

class _IndicadorItemSkeleton extends StatelessWidget {
  const _IndicadorItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SkeletonBox(
          width: AppSizing.iconLg,
          height: AppSizing.iconLg,
          borderRadius: AppSizing.radiusCircular,
        ),
        SizedBox(width: AppSpacing.sm),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 56, height: AppSizing.skeletonLineHeight),
            SizedBox(height: AppSpacing.xxs),
            SkeletonBox(width: 28, height: AppSizing.skeletonTitleHeight),
          ],
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: AppColors.border);
}

// ─── Chips ───────────────────────────────────────────────────────────────────

class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 48, height: AppSizing.skeletonChipHeight),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 72, height: AppSizing.skeletonChipHeight),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 88, height: AppSizing.skeletonChipHeight),
        ],
      ),
    );
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────

class _SolicitudCardSkeleton extends StatelessWidget {
  const _SolicitudCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
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
                  ],
                ),
              ),
              SkeletonBox(
                width: AppSizing.skeletonLabelWidth,
                height: AppSizing.skeletonLineHeight,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(
            width: AppSizing.skeletonTextWidth,
            height: AppSizing.skeletonLineHeight,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SkeletonBox(
                width: AppSizing.miniActionButton,
                height: AppSizing.miniActionButton,
                borderRadius: AppSizing.radiusMd,
              ),
              SizedBox(width: AppSpacing.xs),
              SkeletonBox(
                width: AppSizing.skeletonChipWidthSm,
                height: AppSizing.miniActionButton,
                borderRadius: AppSizing.radiusMd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
