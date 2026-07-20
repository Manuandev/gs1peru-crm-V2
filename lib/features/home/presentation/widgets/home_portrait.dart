// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

/// Layout principal del Home en orientación portrait.
class HomePortrait extends StatelessWidget {
  final HomeLoaded state;

  const HomePortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card embudo sobre fondo con ola azul ──────────────
          _HomeWaveCard(state: state),

          // ── Contenido con padding estándar ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ── Grid de módulos ──────────────────────────────
                HomeMenuCards(state: state),
                const SizedBox(height: AppSpacing.xs),

                // ── Prioridad ahora ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prioridad ahora',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: AppTextStyles.weightBold,
                          ),
                        ),
                        Text(
                          'Casos sin respuesta o con seguimiento vencido',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.goToChats(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Ver todas',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                PrioridadSectionHome(prioridades: state.prioridades),

                // ── Sección inferior condicional ─────────────────
                BlocBuilder<FiltroCubit, FiltroState>(
                  builder: (context, filtroState) {
                    final esModerador = state.usuario.isModerador;
                    final esVistaEquipo =
                        filtroState.vista == FiltroVista.miEquipo;

                    if (esModerador && esVistaEquipo) {
                      return AsesorSectionHome(asesores: state.asesores);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prospectos nuevos',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: AppTextStyles.weightBold,
                              ),
                            ),
                            // CustomTextButton(
                            //   text: 'Ver todos',
                            //   onPressed: () {},
                            // ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ProspectosSectionHome(prospectos: state.prospectos),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fondo con ola + CardTotalesHome encima ────────────────────────────────────
// La ola azul se pinta de arriba hasta la mitad del widget.
// El card es el child y tapa la ola excepto en los márgenes laterales.
class _HomeWaveCard extends StatelessWidget {
  final HomeLoaded state;

  const _HomeWaveCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _HomeWavePainter(colorScheme.primary),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.xs,
        ),
        child: CardTotalesHome(state: state),
      ),
    );
  }
}

class _HomeWavePainter extends CustomPainter {
  final Color color;
  const _HomeWavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const ola = AppSpacing.xl;
    final mitad = size.height / 2;
    final path = Path()
      ..lineTo(0, mitad)
      ..quadraticBezierTo(size.width / 2, mitad + ola, size.width, mitad)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HomeWavePainter old) => old.color != color;
}
