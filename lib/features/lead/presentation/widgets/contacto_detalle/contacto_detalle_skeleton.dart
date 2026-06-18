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
      title: 'Detalle de contacto',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(
                  width: AppSizing.skeletonNameWidth,
                  height: AppSizing.skeletonTitleHeight,
                ),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(
                  width: AppSizing.skeletonTextWidth,
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
// TabBar
// ─────────────────────────────────────────────────────────────────────────────

class _TabBarSkeleton extends StatelessWidget {
  const _TabBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: 48,
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
          _CardSkeleton(filas: 2),
          SizedBox(height: AppSpacing.sm),
          _CardSkeleton(filas: 3),
          SizedBox(height: AppSpacing.sm),
          _CardSkeleton(filas: 3),
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
            if (i < filas - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cuadrado gris del ícono
          SkeletonBox(
            width: AppSizing.iconContainerMd,
            height: AppSizing.iconContainerMd,
            borderRadius: AppSizing.radiusSm,
          ),
          SizedBox(width: AppSpacing.sm),
          // Etiqueta arriba + valor abajo
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
      ),
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
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SkeletonBox(
            width: AppSizing.buttonHeight,
            height: AppSizing.buttonHeight,
            borderRadius: AppSizing.radiusCircular,
          ),
          SkeletonBox(
            width: AppSizing.buttonHeight,
            height: AppSizing.buttonHeight,
            borderRadius: AppSizing.radiusCircular,
          ),
          SkeletonBox(
            width: AppSizing.buttonHeight,
            height: AppSizing.buttonHeight,
            borderRadius: AppSizing.radiusCircular,
          ),
        ],
      ),
    );
  }
}
