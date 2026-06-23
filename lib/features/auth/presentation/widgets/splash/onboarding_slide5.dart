// lib/features/auth/presentation/widgets/splash/onboarding_slide5.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/presentation/widgets/splash/onboarding_slide_base.dart';

/// Slide 5: "Solicitudes y propuestas"
///
/// Layout:
/// • Mockup central (card Propuesta/Solicitud) — centrado horizontalmente
/// • Card "Propuesta Ganada" en el borde izquierdo (parcialmente recortada)
/// • Card "Validación" en el borde derecho (parcialmente recortada)
/// • 3 íconos flotantes (documento, persona, escudo)
class OnboardingSlide5 extends StatelessWidget {
  const OnboardingSlide5({super.key});

  // Alto estimado del card principal (usado para centrar los laterales)
  static const double _altoPrincipal = 242.0;
  // Alto de los cards laterales
  static const double _altoLateral = 148.0;
  // Cuántos px quedan off-screen en cada lateral
  static const double _recorteLateral = 22.0;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideBase(
      titulo: 'Solicitudes y\npropuestas',
      subtitulo:
          'Convierte oportunidades en solicitudes,\ncompleta fichas y valida antes de cobrar.',
      // El mockup tiene padding horizontal extra para que el card central
      // sea ~65 % del ancho de pantalla (los laterales llenan los lados)
      mockup: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: _CardPrincipal(),
      ),
      elementosFlotantes: (cardTop) {
        final centroV = cardTop + _altoPrincipal / 2;
        final topLateral = centroV - _altoLateral / 2;

        return [
          // ── Card lateral izquierdo (recortado) ─────────────────
          Positioned(
            top: topLateral,
            left: -_recorteLateral,
            width: 95,
            child: const _CardPropuestaGanada(),
          ),

          // ── Card lateral derecho (recortado) ───────────────────
          Positioned(
            top: topLateral,
            right: -_recorteLateral,
            width: 100,
            child: const _CardValidacion(),
          ),

          // ── Ícono superior izquierdo: documento blanco ──────────
          Positioned(
            top: cardTop - 52,
            left: 6,
            child: _IconFlotante(
              icono: AppIcons.file,
              fondoColor: Colors.white,
              iconColor: AppColors.primary,
              forma: BoxShape.rectangle,
            ),
          ),

          // ── Ícono superior derecho: persona verde ───────────────
          Positioned(
            top: cardTop - 44,
            right: 6,
            child: _IconFlotante(
              icono: AppIcons.userFilled,
              fondoColor: AppColors.success,
              iconColor: Colors.white,
              forma: BoxShape.circle,
            ),
          ),

          // ── Ícono inferior derecho: escudo azul ─────────────────
          Positioned(
            top: cardTop + _altoPrincipal - 52,
            right: 6,
            child: _IconFlotante(
              icono: AppIcons.escudo,
              fondoColor: AppColors.primary,
              iconColor: Colors.white,
              forma: BoxShape.rectangle,
            ),
          ),
        ];
      },
    );
  }
}

// ── Card principal "Propuesta / Solicitud" ─────────────────────────────────────

class _CardPrincipal extends StatelessWidget {
  const _CardPrincipal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(AppIcons.file, size: AppSizing.iconSm, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Propuesta / Solicitud',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Skeleton de campos del formulario
          _Linea(ancho: double.infinity),
          const SizedBox(height: AppSpacing.xs),
          _Linea(ancho: double.infinity),
          const SizedBox(height: AppSpacing.xs),
          _Linea(ancho: 110),
          const SizedBox(height: AppSpacing.sm),

          // Área de texto simulada
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // Sección cliente
          Text(
            'Información del cliente',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.grey200,
                child: Icon(AppIcons.userFilled, size: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(child: _Linea(ancho: double.infinity)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // Stepper
          const _StepperSolicitud(),
        ],
      ),
    );
  }
}

// ── Card lateral izquierdo: "Propuesta Ganada" ─────────────────────────────────

class _CardPropuestaGanada extends StatelessWidget {
  const _CardPropuestaGanada();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Propuesta',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    fontSize: 9,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizing.radiusXs),
                ),
                child: Text(
                  'Ganada',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const _Linea(ancho: double.infinity),
          const SizedBox(height: 4),
          const _Linea(ancho: 60),
          const SizedBox(height: 4),
          const _Linea(ancho: 40),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.check, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card lateral derecho: "Validación" ────────────────────────────────────────

class _CardValidacion extends StatelessWidget {
  const _CardValidacion();

  static const _items = ['Datos completos', 'Info verificada', 'Listo para cobrar'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validación',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const Icon(AppIcons.checkCircle, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stepper ────────────────────────────────────────────────────────────────────

class _StepperSolicitud extends StatelessWidget {
  const _StepperSolicitud();

  static const _pasos = ['Datos', 'Ficha', 'Validación', 'Listo'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_pasos.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(height: 1.5, color: AppColors.primary),
          );
        }
        final idx = i ~/ 2;
        final esUltimo = idx == _pasos.length - 1;
        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: esUltimo
                    ? const Icon(AppIcons.check, size: 10, color: Colors.white)
                    : Text(
                        '${idx + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _pasos[idx],
              style: AppTextStyles.labelSmall.copyWith(fontSize: 7),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}

// ── Ícono flotante (cuadrado o círculo) ───────────────────────────────────────

class _IconFlotante extends StatelessWidget {
  const _IconFlotante({
    required this.icono,
    required this.fondoColor,
    required this.iconColor,
    required this.forma,
  });

  final IconData icono;
  final Color fondoColor;
  final Color iconColor;
  final BoxShape forma;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: fondoColor,
        shape: forma,
        borderRadius: forma == BoxShape.rectangle
            ? BorderRadius.circular(AppSizing.radiusMd)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Icon(icono, color: iconColor, size: AppSizing.iconMd),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _Linea extends StatelessWidget {
  const _Linea({required this.ancho});
  final double ancho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
    );
  }
}
