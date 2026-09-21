// lib/features/auth/presentation/widgets/splash/onboarding_slide1.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 1: fondo 100 % azul con card 3D central — responsive (2026-09-21).
/// El logo GS1 vive arriba (no hay header separado). El card 3D y los íconos
/// flotantes se arman sobre un lienzo de tamaño fijo ([_tamanoEscena]) que
/// [LienzoEscalado] escala entero al espacio entre el logo y el texto — se ve
/// igual en cualquier celular, sin desbordes (mismo criterio que
/// [OnboardingSlideBase] para los slides 2–6).
class OnboardingSlide1 extends StatelessWidget {
  const OnboardingSlide1({super.key});

  static const double _anchoCard = 220.0;
  static const double _altoCard = 290.0;
  static const double _altoPedestal = 14.0;
  // Lienzo de diseño: mismo ancho que los slides 2–6; alto = margen superior
  // de los flotantes + card + pedestal + aire para la sombra.
  static const Size _tamanoEscena = Size(OnboardingSlideBase.anchoEscena, 340);
  // El texto inferior ocupa como máximo esta fracción del alto; si no entra
  // (pantalla chica o fuente del sistema agrandada) se achica en vez de desbordar.
  static const double _fraccionMaxTexto = 0.3;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, Color(0xFF001A4D)],
        ),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          // Frame transitorio sin espacio real (ej. pantalla 0×0 en el primer
          // frame de celulares antiguos): no se dibuja contenido.
          if (constraints.maxHeight < OnboardingSlideBase.altoMinimoContenido ||
              constraints.maxWidth <= 0) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Logo GS1 + "CRM Perú"
              _LogoRow(),
              // Card 3D + flotantes, escalados al espacio disponible
              const Expanded(
                child: LienzoEscalado(
                  tamanoDiseno: _tamanoEscena,
                  escalaMaxima: OnboardingSlideBase.escalaMaxima,
                  alineacion: Alignment.center,
                  child: _EscenaSlide1(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Texto inferior
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * _fraccionMaxTexto,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: _TextoSlide1(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

// ── Escena: card 3D + flotantes (coordenadas del lienzo de diseño) ─────────────

class _EscenaSlide1 extends StatelessWidget {
  const _EscenaSlide1();

  // Borde superior del card dentro del lienzo (deja lugar a los flotantes
  // que asoman por arriba, `cardTop - 22`).
  static const double _cardTop = OnboardingSlideBase.margenSuperiorEscena;
  static const double _altoCard = OnboardingSlide1._altoCard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          top: _cardTop,
          left: 0,
          right: 0,
          child: Center(
            child: _IlustracionCentral(
              ancho: OnboardingSlide1._anchoCard,
              alto: _altoCard,
              altoPedestal: OnboardingSlide1._altoPedestal,
            ),
          ),
        ),

        // ── Íconos flotantes al lado del card ─────────────────
        const Positioned(
          top: _cardTop - 22,
          left: 12,
          child: _BurbujaChat(color: AppColors.primary),
        ),
        const Positioned(
          top: _cardTop - 22,
          right: 12,
          child: _BurbujaChat(
            color: AppColors.grey100,
            puntosColor: AppColors.grey400,
          ),
        ),
        const Positioned(
          top: _cardTop + _altoCard * 0.28,
          left: 8,
          child: _CirculoFlotante(
            color: AppColors.onboardingPurple,
            icono: AppIcons.leadNuevo,
          ),
        ),
        const Positioned(
          top: _cardTop + _altoCard * 0.28,
          right: 8,
          child: _CirculoFlotante(
            color: AppColors.success,
            icono: AppIcons.userFilled,
          ),
        ),
        Positioned(
          top: _cardTop + _altoCard * 0.62,
          left: 12,
          child: _CardFlotanteDoc(),
        ),
        const Positioned(
          top: _cardTop + _altoCard * 0.62,
          right: 12,
          child: _CirculoFlotante(
            color: Color(0xFF5B4FCF),
            icono: AppIcons.moneda,
          ),
        ),
      ],
    );
  }
}

// ── Logo row ───────────────────────────────────────────────────────────────────

class _LogoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppImages.logoGs1PeruBlanco, height: 34),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 1,
          height: 34,
          color: Colors.white.withValues(alpha: 0.5),
        ),
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

// ── Ilustración central ────────────────────────────────────────────────────────

class _IlustracionCentral extends StatelessWidget {
  const _IlustracionCentral({
    required this.ancho,
    required this.alto,
    required this.altoPedestal,
  });
  final double ancho;
  final double alto;
  final double altoPedestal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-0.15),
          child: Container(
            width: ancho,
            height: alto,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66001A4D),
                  blurRadius: 28,
                  offset: Offset(10, 18),
                ),
              ],
            ),
            child: const _ContenidoCard(),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: ancho + 20,
          height: altoPedestal,
          decoration: BoxDecoration(
            color: const Color(0xFF001A4D),
            borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          ),
        ),
      ],
    );
  }
}

class _ContenidoCard extends StatelessWidget {
  const _ContenidoCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(AppIcons.userFilled, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LineaSimulada(
                      width: 90,
                      height: 8,
                      color: AppColors.grey300,
                    ),
                    const SizedBox(height: 4),
                    _LineaSimulada(
                      width: 65,
                      height: 6,
                      color: AppColors.grey200,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _LineaSimulada(
            width: double.infinity,
            height: 8,
            color: AppColors.grey200,
          ),
          const SizedBox(height: 6),
          _LineaSimulada(width: 140, height: 8, color: AppColors.grey200),
          const SizedBox(height: 6),
          _LineaSimulada(width: 110, height: 8, color: AppColors.grey200),
          const SizedBox(height: 6),
          _LineaSimulada(width: 90, height: 8, color: AppColors.grey200),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Barra(alto: 44),
              _Barra(alto: 66),
              _Barra(alto: 34),
              _Barra(alto: 55),
              _Barra(alto: 78),
              _Barra(alto: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineaSimulada extends StatelessWidget {
  const _LineaSimulada({
    required this.width,
    required this.height,
    required this.color,
  });
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.alto});
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: alto,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXs),
        ),
      ),
    );
  }
}

// ── Texto inferior ─────────────────────────────────────────────────────────────

class _TextoSlide1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Text(
            'Conecta. Gestiona. Cobra.',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Conversaciones, seguimiento y cobranzas\nen una sola app.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flotantes ──────────────────────────────────────────────────────────────────

class _BurbujaChat extends StatelessWidget {
  const _BurbujaChat({required this.color, this.puntosColor = Colors.white});
  final Color color;
  final Color puntosColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CircleAvatar(radius: 3, backgroundColor: puntosColor),
          ),
        ),
      ),
    );
  }
}

class _CirculoFlotante extends StatelessWidget {
  const _CirculoFlotante({required this.color, required this.icono});
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Icon(icono, color: Colors.white, size: AppSizing.iconMd),
    );
  }
}

class _CardFlotanteDoc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.file,
            color: Colors.white,
            size: AppSizing.iconSm,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
