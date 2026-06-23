// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

/// Layout principal del Home en orientación portrait.
///
/// ESTRUCTURA:
/// ```
/// SingleChildScrollView
/// └── Column
///     ├── _HomeHeader          (saludo + subtítulo, fondo primary con curva)
///     └── Padding(horizontal)
///         ├── CardTotalesHome  ("Mi embudo de gestión")
///         ├── HomeMenuCards    (grid 2×2 de módulos)
///         ├── "Prioridad ahora" + PrioridadSectionHome
///         └── [condicional]
///             ├── ProspectosSectionHome  (asesor / moderador en misCasos)
///             └── AsesorSectionHome      (moderador en miEquipo)
/// ```
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
          // ── Header azul con saludo ─────────────────────────────
          _HomeHeader(state: state),

          // ── Contenido con padding estándar ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // ── Mi embudo de gestión ─────────────────────────
                CardTotalesHome(state: state),
                const SizedBox(height: AppSpacing.md),

                // ── Grid de módulos ──────────────────────────────
                HomeMenuCards(state: state),
                const SizedBox(height: AppSpacing.md),

                // ── Prioridad ahora ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prioridad ahora',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                    CustomTextButton(text: 'Ver todas', onPressed: () {}),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Casos sin respuesta o con seguimiento vencido',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PrioridadSectionHome(prioridades: state.prioridades),
                const SizedBox(height: AppSpacing.md),

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
                            CustomTextButton(
                              text: 'Ver todos',
                              onPressed: () {},
                            ),
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

// ── Header azul del home ──────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HomeLoaded state;

  const _HomeHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final primerNombre = state.usuario.userApe.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizing.homeHeaderBottomRadius),
          bottomRight: Radius.circular(AppSizing.homeHeaderBottomRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hola, $primerNombre 👋',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Gestiona tus leads y conversaciones',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark.withValues(
                alpha: AppColors.opacityOnPrimarySubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
