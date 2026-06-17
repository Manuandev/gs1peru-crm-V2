// lib/features/lead/presentation/widgets/list/lead_list_skeleton.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Cuerpo skeleton de la pantalla de lista de leads.
/// Se usa dentro del BlocBuilder de LeadListView mientras el estado es
/// LeadListInitial o LeadListLoading.
/// Espeja el layout de LeadListPortrait: fila de chips + lista de cards.
class LeadListSkeleton extends StatelessWidget {
  const LeadListSkeleton({super.key});

  static const int _cantidadCards = 7;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FiltrosSkeleton(),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _cantidadCards,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LeadCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de filtro
// ─────────────────────────────────────────────────────────────────────────────

// Placeholder de los chips de filtro: mismos padding y scroll que LeadListFilterChips.
class _FiltrosSkeleton extends StatelessWidget {
  const _FiltrosSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthMd),
            SizedBox(width: AppSpacing.sm),
            _ChipSkeleton(ancho: AppSizing.skeletonChipWidthSm),
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
// Card de lead
// ─────────────────────────────────────────────────────────────────────────────

// Espeja exactamente el layout de LeadCard: avatar + info central + timestamp + actions.
class _LeadCardSkeleton extends StatelessWidget {
  const _LeadCardSkeleton();

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
          // Fila superior: avatar + info + timestamp
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circular
              SkeletonBox(
                width: AppSizing.avatarMd,
                height: AppSizing.avatarMd,
                borderRadius: AppSizing.radiusCircular,
              ),
              SizedBox(width: AppSpacing.md),
              // Info central: nombre, canal·interés, empresa
              Expanded(child: _InfoSkeleton()),
              // Timestamp derecho: fecha, elapsed, badge de estado
              _TimestampSkeleton(),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Botones de acción
          _AccionesSkeleton(),
        ],
      ),
    );
  }
}

// Info central skeleton: espejo de _LeadInfo (nombre + canal·interés + empresa).
class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
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
        SizedBox(height: AppSpacing.xxs),
        SkeletonBox(
          width: AppSizing.infoLabelWidth,
          height: AppSizing.skeletonLineHeight,
        ),
      ],
    );
  }
}

// Timestamp derecho skeleton: espejo de _LeadTimestamp (fecha + elapsed + chipEstado).
class _TimestampSkeleton extends StatelessWidget {
  const _TimestampSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SkeletonBox(
          width: AppSizing.skeletonLabelWidth,
          height: AppSizing.skeletonLineHeight,
        ),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(
          width: AppSizing.skeletonLabelWidth,
          height: AppSizing.skeletonLineHeight,
        ),
        SizedBox(height: AppSpacing.xs),
        // Chip de estado (pill)
        SkeletonBox(
          width: AppSizing.skeletonChipWidthSm,
          height: AppSizing.skeletonChipHeight,
          borderRadius: AppSizing.radiusCircular,
        ),
      ],
    );
  }
}

// Fila de botones de acción skeleton: espejo de LeadCardActions (chat + estrella).
class _AccionesSkeleton extends StatelessWidget {
  const _AccionesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(
          width: AppSizing.buttonHeightSmall,
          height: AppSizing.buttonHeightSmall,
          borderRadius: AppSizing.radiusCircular,
        ),
        SizedBox(width: AppSpacing.md),
        SkeletonBox(
          width: AppSizing.buttonHeightSmall,
          height: AppSizing.buttonHeightSmall,
          borderRadius: AppSizing.radiusCircular,
        ),
      ],
    );
  }
}
