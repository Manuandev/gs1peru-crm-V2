// lib/features/auth/presentation/widgets/splash/onboarding_slide_base.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

/// Builder que recibe la posición Y del top del card
/// para posicionar los íconos flotantes justo a sus lados.
typedef FlotantesBuilder = List<Widget> Function(double cardTop);

/// Layout compartido slides 2–6 — responsive (2026-09-21).
///
/// Zona azul arriba: logo + título + subtítulo a tamaño normal (solo se
/// achican si no entran en [_fraccionMaxTexto] del alto).
/// Debajo, la ilustración (mockup + flotantes) se arma sobre un lienzo de
/// tamaño fijo ([anchoEscena] × [_altoEscena]) y [LienzoEscalado] la escala
/// entera al espacio que queda — se ve igual en cualquier celular, sin
/// desbordes ni recortes. La zona azul baja por detrás del borde superior del
/// card y termina en una ola hacia el fondo azul-gris claro.
class OnboardingSlideBase extends StatelessWidget {
  const OnboardingSlideBase({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.mockup,
    this.elementosFlotantes,
  });

  final String titulo;
  final String subtitulo;
  final Widget mockup;
  final FlotantesBuilder? elementosFlotantes;

  /// Ancho de diseño del lienzo de la ilustración (≈ celular de referencia).
  /// Los flotantes se posicionan contra estos bordes, no contra la pantalla.
  /// Público: el slide 1 usa el mismo ancho para escalar igual que el resto.
  static const double anchoEscena = 390.0;
  // Alto de diseño del lienzo: margen superior + mockup más alto (slide 6,
  // ~390 px a este ancho) + aire inferior para la sombra.
  static const double _altoEscena = 430.0;
  /// Espacio sobre el borde superior del card dentro del lienzo — ahí asoman
  /// los flotantes (`cardTop - 22`); los que suben más (slide 5) pintan por
  /// encima del texto, igual que en el diseño original.
  static const double margenSuperiorEscena = 24.0;
  /// Tope de crecimiento de la ilustración en pantallas grandes (tablet).
  static const double escalaMaxima = 1.4;
  /// Por debajo de este alto no hay espacio real para un slide — solo pasa en
  /// frames transitorios (ej. el primero, con pantalla 0×0, en celulares
  /// antiguos): no se dibuja contenido, así nada calcula medidas negativas.
  static const double altoMinimoContenido = 160.0;
  // El bloque de texto ocupa como máximo esta fracción del alto; si no entra
  // (pantalla chica o fuente del sistema agrandada) se achica en vez de desbordar.
  static const double _fraccionMaxTexto = 0.4;
  // Cuánto baja la zona azul por debajo del borde superior del card (en px de
  // diseño) — misma proporción que el diseño original.
  static const double _solapeAzul = 64.0;
  // Ola más pronunciada para la transición azul → gris claro (px de diseño).
  static const double _profundidadOla = 36.0;
  // Fondo de la ilustración: azul-gris muy claro (igual que la referencia).
  static const Color _fondoIlustracion = Color(0xFFEEF2FF);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _fondoIlustracion,
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxHeight < altoMinimoContenido ||
              constraints.maxWidth <= 0) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Zona azul: logo + título + subtítulo ─────────────────
              ColoredBox(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                    AppSpacing.screenPadding,
                    0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * _fraccionMaxTexto,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: math.max(
                          0,
                          constraints.maxWidth - AppSpacing.screenPadding * 2,
                        ),
                        child: _BloqueTexto(
                          titulo: titulo,
                          subtitulo: subtitulo,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Ilustración escalada al espacio restante ─────────────
              Expanded(
                child: _ZonaIlustracion(
                  mockup: mockup,
                  elementosFlotantes: elementosFlotantes,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Bloque de texto ────────────────────────────────────────────────────────────

class _BloqueTexto extends StatelessWidget {
  const _BloqueTexto({required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoRow(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: AppTextStyles.weightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

// ── Zona de ilustración ────────────────────────────────────────────────────────

/// Fondo (continuación de la zona azul + ola) y lienzo escalado con el mockup
/// y los flotantes. El fondo usa la misma escala que el lienzo para que el
/// borde azul siempre caiga a la misma altura del card.
class _ZonaIlustracion extends StatelessWidget {
  const _ZonaIlustracion({required this.mockup, this.elementosFlotantes});

  final Widget mockup;
  final FlotantesBuilder? elementosFlotantes;

  static const Size _tamanoEscena = Size(
    OnboardingSlideBase.anchoEscena,
    OnboardingSlideBase._altoEscena,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final escala = ResponsiveHelper.escalaLienzo(
          constraints.biggest,
          _tamanoEscena,
          escalaMaxima: OnboardingSlideBase.escalaMaxima,
        );
        if (escala <= 0) return const SizedBox.shrink();

        final finAzul = (OnboardingSlideBase.margenSuperiorEscena +
                OnboardingSlideBase._solapeAzul) *
            escala;
        final ola = OnboardingSlideBase._profundidadOla * escala;

        return Stack(
          // Los flotantes que suben más que el margen superior pintan por
          // encima del texto, como en el diseño original.
          clipBehavior: Clip.none,
          children: [
            // ── La zona azul continúa por detrás del borde del card ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: finAzul,
              child: const ColoredBox(color: AppColors.primary),
            ),

            // ── Ola de transición azul → azul-gris ─────────────────
            Positioned(
              top: finAzul - ola,
              left: 0,
              right: 0,
              height: ola * 2,
              child: ClipPath(
                clipper: const _OlaClipper(),
                child: const ColoredBox(
                  color: OnboardingSlideBase._fondoIlustracion,
                ),
              ),
            ),

            // ── Mockup + flotantes sobre el lienzo de diseño ───────
            LienzoEscalado(
              tamanoDiseno: _tamanoEscena,
              escalaMaxima: OnboardingSlideBase.escalaMaxima,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: OnboardingSlideBase.margenSuperiorEscena,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: mockup,
                  ),
                  // Íconos flotantes relativos al cardTop (coordenadas del lienzo)
                  if (elementosFlotantes != null)
                    ...elementosFlotantes!(
                      OnboardingSlideBase.margenSuperiorEscena,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Logo row ────────────────────────────────────────────────────────────────────

class _LogoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppImages.logoGs1PeruBlanco, height: 34),
        const SizedBox(width: AppSpacing.sm),
        Container(width: 1, height: 34, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'CRM Perú',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
      ],
    );
  }
}

// ── Ola clipper ────────────────────────────────────────────────────────────────

class _OlaClipper extends CustomClipper<Path> {
  const _OlaClipper();

  @override
  Path getClip(Size size) {
    final mitad = size.height / 2;
    return Path()
      ..moveTo(0, mitad)
      ..quadraticBezierTo(size.width / 2, 0, size.width, mitad)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_OlaClipper old) => false;
}
