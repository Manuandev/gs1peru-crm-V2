// lib/features/auth/presentation/widgets/recuperar_clave/recuperar_clave_ilustracion_widget.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

/// Ilustración decorativa de la zona azul de "Olvidé mi clave".
///
/// Construida 100% con widgets Flutter (sin imágenes PNG).
/// Simula un sobre con candado, avión de papel y badges decorativos.
class RecuperarClaveIlustracionWidget extends StatelessWidget {
  const RecuperarClaveIlustracionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizing.loginIlustracionWidth,
      height: AppSizing.loginIlustracionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Sobre central con ícono de email ───────────────────
          Positioned(
            left: AppSpacing.xl,
            top: AppSpacing.lg,
            right: 0,
            bottom: AppSpacing.lg,
            child: _SobreCentral(),
          ),

          // ── Candado encima del sobre ────────────────────────────
          Positioned(
            right: AppSpacing.xl,
            top: 0,
            child: _CandadoDecorativo(),
          ),

          // ── Avión de papel (esquina superior derecha) ───────────
          Positioned(
            right: AppSpacing.xxs,
            top: AppSpacing.xxs,
            child: Transform.rotate(
              angle: -0.6,
              child: Icon(
                AppIcons.send,
                size: AppSizing.iconMd,
                color: AppColors.white(0.85),
              ),
            ),
          ),

          // ── Badge morado con "@" ────────────────────────────────
          Positioned(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
            child: const _BadgeArroba(),
          ),

          // ── Badge azul oscuro con check ─────────────────────────
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.xxs,
            child: const _BadgeCheck(),
          ),

          // ── Grid de puntos decorativos (esquina inferior derecha) ─
          Positioned(
            right: 0,
            bottom: 0,
            child: const _GridPuntosDecor(),
          ),
        ],
      ),
    );
  }
}

// ── Sobre central ────────────────────────────────────────────────────────────

class _SobreCentral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.18),
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, AppSizing.shadowOffsetCardY),
          ),
        ],
      ),
      child: Icon(
        AppIcons.email,
        size: AppSizing.iconLg,
        color: AppColors.primary,
      ),
    );
  }
}

// ── Candado decorativo ───────────────────────────────────────────────────────

class _CandadoDecorativo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconLg,
      height: AppSizing.iconLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.15),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        AppIcons.lock,
        size: AppSizing.iconMd,
        color: AppColors.primary,
      ),
    );
  }
}

// ── Badge "@" morado ─────────────────────────────────────────────────────────

class _BadgeArroba extends StatelessWidget {
  const _BadgeArroba();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accentPurple,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.4),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '@',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textOnDark,
            fontSize: AppTextStyles.sizeSm,
          ),
        ),
      ),
    );
  }
}

// ── Badge check azul ─────────────────────────────────────────────────────────

class _BadgeCheck extends StatelessWidget {
  const _BadgeCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWithOpacity(0.4),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        AppIcons.check,
        size: AppSizing.iconActionSm,
        color: AppColors.textOnDark,
      ),
    );
  }
}

// ── Grid de puntos decorativos ───────────────────────────────────────────────

class _GridPuntosDecor extends StatelessWidget {
  const _GridPuntosDecor();

  static const int _filas = 3;
  static const int _columnas = 3;
  static const double _espaciado = 6.0;
  static const double _diametro = 3.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_filas, (fila) {
        return Padding(
          padding: const EdgeInsets.only(bottom: _espaciado),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_columnas, (col) {
              return Padding(
                padding: const EdgeInsets.only(right: _espaciado),
                child: Container(
                  width: _diametro,
                  height: _diametro,
                  decoration: BoxDecoration(
                    color: AppColors.white(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
