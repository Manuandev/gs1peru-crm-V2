// lib/features/auth/presentation/widgets/splash/splash_landscape.dart

import 'dart:math' show pi;

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

class SplashLandscape extends StatefulWidget {
  const SplashLandscape({super.key});

  @override
  State<SplashLandscape> createState() => _SplashLandscapeState();
}

class _SplashLandscapeState extends State<SplashLandscape>
    with TickerProviderStateMixin {
  // ── Controladores ──────────────────────────────────────────────────────────
  late final AnimationController _seqController;
  late final AnimationController _ringController;
  late final AnimationController _pulseController;

  // ── Animaciones de intro ───────────────────────────────────────────────────
  late final Animation<double> _ringsOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textOffset;
  late final Animation<double> _dotOpacity;

  // ── Animaciones de loop ────────────────────────────────────────────────────
  late final Animation<double> _ring1;
  late final Animation<double> _ring2;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _seqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo + anillos: 0–600 ms → Interval 0.000–0.375
    _ringsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.0, 0.375, curve: Curves.easeIn),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.0, 0.375, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.0, 0.375, curve: Curves.easeOutCubic),
      ),
    );

    // Nombre app: 600–1100 ms → Interval 0.375–0.6875
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.375, 0.6875, curve: Curves.easeIn),
      ),
    );
    _textOffset = Tween<double>(begin: AppSpacing.lg, end: 0.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.375, 0.6875, curve: Curves.easeOut),
      ),
    );

    // Dot de carga: 1100–1500 ms → Interval 0.6875–0.9375
    _dotOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seqController,
        curve: const Interval(0.6875, 0.9375, curve: Curves.easeIn),
      ),
    );

    _ring1 = Tween<double>(begin: 0, end: 2 * pi).animate(_ringController);
    _ring2 = Tween<double>(begin: 2 * pi, end: 0).animate(_ringController);

    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _seqController.forward().then((_) {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _seqController.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_seqController, _ringController, _pulseController]),
      builder: (context, _) {
        final escalaLogo = _logoScale.value * _pulse.value;

        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Anillos + Logo ─────────────────────────────────────────
              SizedBox(
                width: AppSizing.animRingOuter,
                height: AppSizing.animRingOuter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _ringsOpacity.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _Anillo(
                            angulo: _ring1.value,
                            tamano: AppSizing.animRingOuter,
                            color: AppColors.splashRing1,
                          ),
                          _Anillo(
                            angulo: _ring2.value,
                            tamano: AppSizing.animRingMid,
                            color: AppColors.splashRing2,
                          ),
                          _Anillo(
                            angulo: _ring1.value * 1.5,
                            tamano: AppSizing.animRingInner,
                            color: AppColors.splashRing3,
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: escalaLogo,
                        child: SizedBox(
                          width: AppSizing.iconDisplay,
                          height: AppSizing.iconDisplay,
                          child: SvgPicture.asset(
                            AppImages.logoGs1PeruBlanco,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),

              // ── Nombre + indicador ──────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textOffset.value),
                      child: Text(
                        AppConstants.nombreApp,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textOnDark,
                          letterSpacing: AppTextStyles.letterSpacingWide,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Opacity(
                    opacity: _dotOpacity.value,
                    child: const _PuntoCarga(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────────

class _Anillo extends StatelessWidget {
  const _Anillo({
    required this.angulo,
    required this.tamano,
    required this.color,
  });

  final double angulo;
  final double tamano;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angulo,
      child: Container(
        width: tamano,
        height: tamano,
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

class _PuntoCarga extends StatefulWidget {
  const _PuntoCarga();

  @override
  State<_PuntoCarga> createState() => _PuntoCargaState();
}

class _PuntoCargaState extends State<_PuntoCarga>
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
        width: AppSizing.splashDotSize,
        height: AppSizing.splashDotSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
