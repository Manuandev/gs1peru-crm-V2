// lib/features/auth/presentation/widgets/splash/onboarding_carousel.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/dots_indicador.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide1.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide2.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide3.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide4.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide5.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide6.dart';

/// Carrusel de 6 slides con footer fijo (dots + botón).
///
/// [soloMostrarPrimeraSlide] — cuando es `true`, muestra únicamente la primera
/// slide de forma estática, sin gestos de swipe ni footer. Se usa como
/// pantalla de carga mientras el SplashBloc resuelve la sesión (escenarios 2/3).
///
/// [alEmpezar] — callback invocado cuando el usuario pulsa "Finalizar" en el
/// último slide. Puede ser `null` cuando [soloMostrarPrimeraSlide] es `true`,
/// ya que en ese modo nunca se invoca.
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    this.alEmpezar,
    this.soloMostrarPrimeraSlide = false,
  });

  final VoidCallback? alEmpezar;
  final bool soloMostrarPrimeraSlide;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  int _indice = 0;
  static const int _total = 6;

  bool get _esSlide1 => _indice == 0;
  bool get _esUltimo => _indice == _total - 1;

  void _siguiente() {
    if (_indice < _total - 1) setState(() => _indice++);
  }

  void _anterior() {
    if (_indice > 0) setState(() => _indice--);
  }

  void _empezar() {
    if (!mounted) return;
    widget.alEmpezar?.call();
  }

  Widget _buildContenido() {
    return switch (_indice) {
      0 => const OnboardingSlide1(),
      1 => const OnboardingSlide2(),
      2 => const OnboardingSlide3(),
      3 => const OnboardingSlide4(),
      4 => const OnboardingSlide5(),
      5 => const OnboardingSlide6(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Modo estático: primera slide sin controles (pantalla de carga para usuarios recurrentes)
    if (widget.soloMostrarPrimeraSlide) {
      return const Material(
        color: Colors.white,
        child: SafeArea(child: OnboardingSlide1()),
      );
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ── Contenido: zona deslizable ───────────────────────────
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v < -300) _siguiente();
                  if (v > 300) _anterior();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: SizedBox.expand(
                    key: ValueKey(_indice),
                    child: _buildContenido(),
                  ),
                ),
              ),
            ),

            // ── Footer fijo: dots + botón ────────────────────────────
            _FooterCarousel(
              indice: _indice,
              total: _total,
              sobreFondoAzul: _esSlide1,
              botonTexto: _esUltimo ? 'Finalizar' : 'Continuar',
              alContinuar: _esUltimo ? _empezar : _siguiente,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────────

class _FooterCarousel extends StatelessWidget {
  const _FooterCarousel({
    required this.indice,
    required this.total,
    required this.sobreFondoAzul,
    required this.botonTexto,
    required this.alContinuar,
  });

  final int indice;
  final int total;
  final bool sobreFondoAzul;
  final String botonTexto;
  final VoidCallback alContinuar;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: sobreFondoAzul ? const Color(0xFF001A4D) : Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DotsIndicador(
            total: total,
            actual: indice,
            sobreFondoAzul: sobreFondoAzul,
          ),
          const SizedBox(height: AppSpacing.md),
          sobreFondoAzul
              ? CustomPrimaryButton(
                  text: botonTexto,
                  icon: AppIcons.forward,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: alContinuar,
                )
              : CustomPrimaryButton(
                  text: botonTexto,
                  icon: AppIcons.forward,
                  onPressed: alContinuar,
                ),
        ],
      ),
    );
  }
}
