// lib/features/lead/presentation/widgets/contacto_detalle/contacto_detalle_skeleton.dart

import 'package:flutter/material.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class ContactoDetalleSkeleton extends StatelessWidget {
  const ContactoDetalleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: const SizedBox.shrink(),
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(AppIcons.backIos),
          onPressed: () => context.goBack(),
        ),
      ],
      footer: const _FooterSkeleton(),
      body: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSkeleton(),
            _StepperSkeleton(),
            _TabBarSkeleton(),
            _InfoTabSkeleton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header oscuro
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: const Row(
        children: [
          SkeletonBox(
            width: AppSizing.avatarMd,
            height: AppSizing.avatarMd,
            borderRadius: AppSizing.radiusCircular,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: SkeletonBox(
              width: AppSizing.skeletonNameWidth,
              height: AppSizing.skeletonTitleHeight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stepper de 4 fases
// ─────────────────────────────────────────────────────────────────────────────

class _StepperSkeleton extends StatelessWidget {
  const _StepperSkeleton();

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
          Expanded(child: _PasoSkeleton()),
          Expanded(child: _PasoSkeleton()),
          Expanded(child: _PasoSkeleton()),
          _PasoSkeleton(),
        ],
      ),
    );
  }
}

class _PasoSkeleton extends StatelessWidget {
  const _PasoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(
          width: AppSizing.skeletonChipWidthSm,
          height: AppSizing.skeletonLineHeight,
        ),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(
          width: AppSizing.chatStepperCircleSize,
          height: AppSizing.chatStepperCircleSize,
          borderRadius: AppSizing.radiusCircular,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TabBar
// ─────────────────────────────────────────────────────────────────────────────

class _TabBarSkeleton extends StatelessWidget {
  const _TabBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: AppSizing.tabBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: SkeletonBox(
                width: AppSizing.skeletonChipWidthSm,
                height: AppSizing.skeletonLineHeight,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SkeletonBox(
                width: AppSizing.skeletonChipWidthMd,
                height: AppSizing.skeletonLineHeight,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SkeletonBox(
                width: AppSizing.skeletonChipWidthSm,
                height: AppSizing.skeletonLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cuerpo de la pestaña Info
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTabSkeleton extends StatelessWidget {
  const _InfoTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardSkeleton(filas: 7),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: AppSizing.buttonHeight),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final int filas;

  const _CardSkeleton({required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < filas; i++) ...[
            const _FilaSkeleton(),
            if (i < filas - 1) const Divider(height: AppSizing.hairline),
          ],
        ],
      ),
    );
  }
}

class _FilaSkeleton extends StatelessWidget {
  const _FilaSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _CampoSkeleton()),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _CampoSkeleton()),
        ],
      ),
    );
  }
}

class _CampoSkeleton extends StatelessWidget {
  const _CampoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          borderRadius: AppSizing.radiusXs,
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
              SkeletonBox(height: AppSizing.skeletonTitleHeight),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _FooterSkeleton extends StatelessWidget {
  const _FooterSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: const Row(
        children: [
          Expanded(
            child: SkeletonBox(height: AppSizing.buttonHeightSmall),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SkeletonBox(height: AppSizing.buttonHeightSmall),
          ),
        ],
      ),
    );
  }
}
