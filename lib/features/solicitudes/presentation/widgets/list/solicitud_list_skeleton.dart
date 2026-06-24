// lib/features/solicitudes/presentation/widgets/list/solicitud_list_skeleton.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class SolicitudListSkeleton extends StatelessWidget {
  const SolicitudListSkeleton({super.key});

  static const int _cantidadCards = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Skeleton de indicadores ────────────────────────────
        const _IndicadoresSkeleton(),

        // ── Skeleton de tabs ───────────────────────────────────
        const _TabsSkeleton(),

        // ── Skeleton de cards ──────────────────────────────────
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _cantidadCards,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SolicitudCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Indicadores skeleton ─────────────────────────────────────────────────────

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
          _VerticalDivider(),
          Expanded(child: _IndicadorItemSkeleton()),
          _VerticalDivider(),
          Expanded(child: _IndicadorItemSkeleton()),
          _VerticalDivider(),
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
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(
          width: AppSizing.iconXl,
          height: AppSizing.iconXl,
          borderRadius: AppSizing.radiusCircular,
        ),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(width: 48, height: AppSizing.skeletonLineHeight),
        SizedBox(height: AppSpacing.xxs),
        SkeletonBox(width: 24, height: AppSizing.skeletonTitleHeight),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 72, color: AppColors.border);
  }
}

// ─── Tabs skeleton ────────────────────────────────────────────────────────────

class _TabsSkeleton extends StatelessWidget {
  const _TabsSkeleton();

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
          SkeletonBox(width: 44, height: AppSizing.skeletonChipHeight),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 64, height: AppSizing.skeletonChipHeight),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 76, height: AppSizing.skeletonChipHeight),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 120, height: AppSizing.skeletonChipHeight),
        ],
      ),
    );
  }
}

// ─── Card skeleton ────────────────────────────────────────────────────────────

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
                width: AppSizing.avatarMd,
                height: AppSizing.avatarMd,
                borderRadius: AppSizing.radiusCircular,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: AppSizing.skeletonNameWidth,
                      height: AppSizing.skeletonTitleHeight,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(
                width: AppSizing.skeletonNameWidth,
                height: AppSizing.skeletonLineHeight,
              ),
              SkeletonBox(
                width: AppSizing.skeletonChipWidthSm,
                height: AppSizing.skeletonLineHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
