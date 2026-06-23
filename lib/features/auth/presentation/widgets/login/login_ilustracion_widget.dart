// lib/features/auth/presentation/widgets/login/login_ilustracion_widget.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

/// Ilustración decorativa de la zona azul del login.
///
/// Construida 100% con widgets Flutter (sin imágenes PNG).
/// Simula una interfaz de contacto/lead con burbujas de chat,
/// avatares, mini gráfico y badge de dólar.
class LoginIlustracionWidget extends StatelessWidget {
  const LoginIlustracionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizing.loginIlustracionWidth,
      height: AppSizing.loginIlustracionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Tarjeta central blanca con contenido simulado ──────────
          Positioned(
            left: AppSpacing.xl,
            top: AppSpacing.lg,
            right: 0,
            bottom: AppSpacing.lg,
            child: _TarjetaCentral(),
          ),

          // ── Burbuja de chat superior izquierda ─────────────────────
          Positioned(
            left: 0,
            top: 0,
            child: _BurbujaChat(alineadaIzquierda: true),
          ),

          // ── Burbuja de chat superior derecha ───────────────────────
          Positioned(
            right: AppSpacing.xs,
            top: AppSpacing.sm,
            child: _BurbujaChat(alineadaIzquierda: false),
          ),

          // ── Avatar azul (asesor) ────────────────────────────────────
          Positioned(
            left: AppSpacing.sm,
            bottom: AppSpacing.lg,
            child: _Avatar(
              color: AppColors.primary,
              iconColor: AppColors.textOnDark,
            ),
          ),

          // ── Avatar verde (contacto) ─────────────────────────────────
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.xs,
            child: _Avatar(
              color: AppColors.success,
              iconColor: AppColors.textOnDark,
            ),
          ),

          // ── Badge morado con $ ──────────────────────────────────────
          Positioned(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
            child: const _BadgeDolar(),
          ),

          // ── Grid de puntos decorativos ──────────────────────────────
          Positioned(
            right: 0,
            bottom: 0,
            child: const _GridPuntos(),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta central ─────────────────────────────────────────────────────────

class _TarjetaCentral extends StatelessWidget {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Línea de nombre simulada (azul oscuro)
          Container(
            width: 72,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.75),
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Línea de datos corta (gris)
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Mini gráfico de barras (3 barras de distinta altura)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Barra(altura: 24, color: AppColors.primaryWithOpacity(0.9)),
              const SizedBox(width: AppSpacing.xxs),
              _Barra(altura: 16, color: AppColors.primaryWithOpacity(0.6)),
              const SizedBox(width: AppSpacing.xxs),
              _Barra(altura: 30, color: AppColors.primaryWithOpacity(0.8)),
              const SizedBox(width: AppSpacing.xxs),
              _Barra(altura: 20, color: AppColors.primaryWithOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  final double altura;
  final Color color;

  const _Barra({required this.altura, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: altura,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizing.radiusXxs),
      ),
    );
  }
}

// ── Burbuja de chat ──────────────────────────────────────────────────────────

class _BurbujaChat extends StatelessWidget {
  final bool alineadaIzquierda;

  const _BurbujaChat({required this.alineadaIzquierda});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizing.radiusMd),
          topRight: Radius.circular(AppSizing.radiusMd),
          bottomLeft: alineadaIzquierda
              ? const Radius.circular(AppSizing.radiusXs)
              : Radius.circular(AppSizing.radiusMd),
          bottomRight: alineadaIzquierda
              ? Radius.circular(AppSizing.radiusMd)
              : const Radius.circular(AppSizing.radiusXs),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.12),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PuntoChatDot(),
          const SizedBox(width: 2),
          _PuntoChatDot(),
          const SizedBox(width: 2),
          _PuntoChatDot(),
        ],
      ),
    );
  }
}

class _PuntoChatDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Avatar circular ──────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Color color;
  final Color iconColor;

  const _Avatar({required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.avatarSm,
      height: AppSizing.avatarSm,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.15),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(AppIcons.user, size: AppSizing.iconActionSm, color: iconColor),
    );
  }
}

// ── Badge dólar ──────────────────────────────────────────────────────────────

class _BadgeDolar extends StatelessWidget {
  const _BadgeDolar();

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
          '\$',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textOnDark,
            fontSize: AppTextStyles.sizeSm,
          ),
        ),
      ),
    );
  }
}

// ── Grid de puntos decorativos ───────────────────────────────────────────────

class _GridPuntos extends StatelessWidget {
  const _GridPuntos();

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
