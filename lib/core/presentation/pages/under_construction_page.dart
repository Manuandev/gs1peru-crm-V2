// lib/core/presentation/pages/under_construction_page.dart
// lib

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';

class UnderConstructionPage extends StatefulWidget {
  const UnderConstructionPage({super.key, required this.routeName});
  final String routeName;

  @override
  State<UnderConstructionPage> createState() => _UnderConstructionPageState();
}

class _UnderConstructionPageState extends State<UnderConstructionPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  late final Animation<double> _ring1;
  late final Animation<double> _ring2;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ring1 = Tween<double>(begin: 0, end: 2 * 3.14159).animate(_ctrl);
    _ring2 = Tween<double>(begin: 2 * 3.14159, end: 0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: widget.routeName,
      drawerSide: DrawerSide.left,
      onPop: () => context.goToHome(),
      // appBarLeadingButtons: [
      //   IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
      //     onPressed: () => context.goToHome(),
      //   ),
      // ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSizing.animRingOuter,
              height: AppSizing.animRingOuter,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    _RotatingRing(
                      angle: _ring1.value,
                      size: AppSizing.animRingOuter,
                      color: AppColors.grey500.withValues(alpha: 0.25),
                    ),
                    _RotatingRing(
                      angle: _ring2.value,
                      size: AppSizing.animRingMid,
                      color: AppColors.grey500.withValues(alpha: 0.20),
                    ),
                    _RotatingRing(
                      angle: _ring1.value * 1.5,
                      size: AppSizing.animRingInner,
                      color: AppColors.grey500.withValues(alpha: 0.15),
                    ),
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: AppSizing.animRingCenter,
                        height: AppSizing.animRingCenter,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizing.radiusLg,
                          ),
                          border: Border.all(
                            color: AppColors.grey500.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppImages.logoTheme(context),
                            width: AppSizing.animLogoSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl), // era 28
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BlinkingDot(),
                  const SizedBox(width: AppSpacing.xs),
                  const Text('En desarrollo', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg), // era 20
            Text(
              'Página en construcción',
              style: AppTextStyles.headlineSmall.copyWith(
                letterSpacing: AppTextStyles.letterSpacingTight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm), // era 8
            Text(
              'Esta sección estará disponible pronto.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingRing extends StatelessWidget {
  const _RotatingRing({
    required this.angle,
    required this.size,
    required this.color,
  });
  final double angle;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: AppSizing.animRingStroke,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
