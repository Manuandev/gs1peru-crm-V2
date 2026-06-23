// lib/features/auth/presentation/widgets/splash/onboarding_slide_base.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

/// Builder que recibe la posición Y del top del card
/// para posicionar los íconos flotantes justo a sus lados.
typedef FlotantesBuilder = List<Widget> Function(double cardTop);

/// Layout compartido slides 2–6.
///
/// Zona azul (~42 % del alto): logo + título + subtítulo centrados.
/// Transición: ola pronunciada hacia el fondo azul-gris claro.
/// Card: empieza justo después del subtítulo (~16 px de separación).
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

  // La zona azul ocupa el 42 % del alto disponible (header+título+subtítulo justo).
  static const double _fraccionAzul = 0.42;
  // Ola más pronunciada para la transición azul → gris claro.
  static const double _profundidadOla = 36.0;
  // Fondo de la ilustración: azul-gris muy claro (igual que la referencia).
  static const Color _fondoIlustracion = Color(0xFFEEF2FF);
  // Altura estimada del bloque logo+título+subtítulo (con gaps).
  static const double _altoContenidoTexto = 140.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final alto = constraints.maxHeight;
        final altoAzul = alto * _fraccionAzul;
        final altoZonaTexto = altoAzul - _profundidadOla / 2;

        // Borde inferior del texto (centrado dentro de altoZonaTexto)
        final textoBottom =
            (altoZonaTexto - _altoContenidoTexto) / 2 + _altoContenidoTexto;

        // Card empieza 16 px después del subtítulo
        final cardTop = textoBottom + 16;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Fondo bicolor: azul arriba, azul-gris claro abajo ──
            Column(
              children: [
                SizedBox(
                  height: altoAzul,
                  child: Container(color: AppColors.primary),
                ),
                Expanded(child: Container(color: _fondoIlustracion)),
              ],
            ),

            // ── Ola de transición azul → azul-gris ─────────────────
            Positioned(
              top: altoAzul - _profundidadOla,
              left: 0,
              right: 0,
              height: _profundidadOla * 2,
              child: ClipPath(
                clipper: const _OlaClipper(),
                child: Container(color: _fondoIlustracion),
              ),
            ),

            // ── Zona azul: logo + título + subtítulo ─────────────────
            Positioned(
              top: 0,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              height: altoZonaTexto,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),

            // ── Mockup: posicionado justo debajo del subtítulo ──────
            Positioned(
              top: cardTop,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: mockup,
            ),

            // ── Íconos flotantes relativos al cardTop ────────────────
            if (elementosFlotantes != null) ...elementosFlotantes!(cardTop),
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
