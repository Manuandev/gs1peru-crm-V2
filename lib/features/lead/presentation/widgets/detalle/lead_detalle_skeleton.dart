// lib/features/lead/presentation/widgets/detalle/lead_detalle_skeleton.dart

import 'package:app_crm/config/index_config.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
// Importación directa para evitar ciclo: index_lead → skeleton → index_lead
import 'package:app_crm/features/lead/presentation/widgets/detalle/lead_detalle_actions.dart';
import 'package:app_crm/features/lead/presentation/widgets/detalle/lead_detalle_info_card.dart';

/// Pantalla skeleton del detalle de lead.
/// Se muestra mientras LeadDetalleBloc está en estado Initial o Loading.
/// Espeja la estructura exacta de _DetalleScaffold para que la transición
/// a datos reales no genere salto de layout.
class LeadDetalleSkeleton extends StatelessWidget {
  const LeadDetalleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: const _AppBarTituloSkeleton(),
      drawerSide: DrawerSide.none,
      // Guard en InfoLeadCubit maneja el tap si se presiona antes de cargar
      footer: LeadDetalleActions(onEditar: () {}),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(AppIcons.backIos),
          onPressed: () => context.goBack(),
        ),
      ],
      body: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepperSkeleton(),
            _UltimaInteraccionSkeleton(),
            _InfoCardSkeleton(titulo: 'CONTACTO', filasCount: 2),
            SizedBox(height: AppSpacing.sm),
            _InfoCardSkeleton(titulo: 'CONTEXTO', filasCount: 3),
            SizedBox(height: AppSpacing.md),
            _ComentariosSkeleton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

// Título skeleton: etiqueta "LEAD" real + SkeletonBox para el nombre.
class _AppBarTituloSkeleton extends StatelessWidget {
  const _AppBarTituloSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LEAD',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
        ),
        const SizedBox(height: AppSpacing.xxs),
        const SkeletonBox(
          width: AppSizing.skeletonNameWidth,
          height: AppSizing.skeletonTitleHeight,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stepper
// ─────────────────────────────────────────────────────────────────────────────

// Stepper skeleton: misma estructura de padding/layout que LeadDetalleStepper.
class _StepperSkeleton extends StatelessWidget {
  const _StepperSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "ETAPA" es texto estático — siempre visible desde el primer frame
              _EtapaLabel(),
              SkeletonBox(
                width: AppSizing.skeletonTextWidth,
                height: AppSizing.skeletonLineHeight,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _StepperRowSkeleton(),
        ],
      ),
    );
  }
}

// Texto "ETAPA" extraído para poder ser const dentro de la Column const.
class _EtapaLabel extends StatelessWidget {
  const _EtapaLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'ETAPA',
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
    );
  }
}

// Fila de 4 círculos skeleton + conectores.
class _StepperRowSkeleton extends StatelessWidget {
  const _StepperRowSkeleton();

  static const int _totalPasos = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _totalPasos; i++) ...[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SkeletonBox(
                  width: AppSizing.stepperCircleSize,
                  height: AppSizing.stepperCircleSize,
                  borderRadius: AppSizing.radiusCircular,
                ),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(
                  width: AppSizing.skeletonLabelWidth,
                  height: AppSizing.skeletonLineHeight,
                ),
              ],
            ),
          ),
          if (i < _totalPasos - 1)
            SizedBox(
              width: AppSpacing.md,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: (AppSizing.stepperCircleSize - AppSizing.hairline) / 2,
                ),
                child: Container(
                  height: AppSizing.hairline,
                  color: AppColors.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Última interacción
// ─────────────────────────────────────────────────────────────────────────────

// Ícono de reloj real + placeholder de texto.
class _UltimaInteraccionSkeleton extends StatelessWidget {
  const _UltimaInteraccionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.time, size: AppSizing.iconSm, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            const SkeletonBox(
              width: AppSizing.skeletonTextWidth,
              height: AppSizing.skeletonLineHeight,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cards de información
// ─────────────────────────────────────────────────────────────────────────────

// Card de información skeleton — reutiliza LeadInfoSectionCard para mantener
// exactamente el mismo borde, radio y padding que la versión real.
class _InfoCardSkeleton extends StatelessWidget {
  final String titulo;
  final int filasCount;

  const _InfoCardSkeleton({required this.titulo, required this.filasCount});

  @override
  Widget build(BuildContext context) {
    return LeadInfoSectionCard(
      titulo: titulo,
      filas: [
        for (int i = 0; i < filasCount; i++) ...[
          if (i > 0)
            const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          const _InfoFilaSkeleton(),
        ],
      ],
    );
  }
}

// Fila de info skeleton: espejo exacto del layout de _InfoFila.
class _InfoFilaSkeleton extends StatelessWidget {
  const _InfoFilaSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Ícono skeleton (circular, mismo ancho que el contenedor real)
          SkeletonBox(
            width: AppSizing.iconSearch,
            height: AppSizing.iconSearch,
            borderRadius: AppSizing.radiusCircular,
          ),
          SizedBox(width: AppSpacing.sm),
          // Etiqueta — mismo ancho fijo que infoLabelWidth en _InfoFila
          SkeletonBox(
            width: AppSizing.infoLabelWidth,
            height: AppSizing.skeletonLineHeight,
          ),
          SizedBox(width: AppSpacing.sm),
          // Valor — ocupa el espacio restante
          Expanded(child: SkeletonBox(height: AppSizing.skeletonLineHeight)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comentarios
// ─────────────────────────────────────────────────────────────────────────────

// Sección de comentarios skeleton: header + 3 burbujas + placeholder de botón.
class _ComentariosSkeleton extends StatelessWidget {
  const _ComentariosSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ComentariosHeaderSkeleton(),
          _ComentarioBubbleSkeleton(),
          _ComentarioBubbleSkeleton(),
          _ComentarioBubbleSkeleton(),
          SizedBox(height: AppSpacing.xs),
          // Placeholder del botón "Agregar comentario"
          SkeletonBox(height: AppSizing.buttonHeightSmall),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// Header "Comentarios" + placeholder del link "Ver todos".
class _ComentariosHeaderSkeleton extends StatelessWidget {
  const _ComentariosHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Comentarios', style: AppTextStyles.titleSmall),
        const SkeletonBox(
          width: AppSizing.skeletonLabelWidth,
          height: AppSizing.skeletonLineHeight,
        ),
      ],
    );
  }
}

// Burbuja de comentario skeleton: espejo de _ComentarioBubble.
class _ComentarioBubbleSkeleton extends StatelessWidget {
  const _ComentarioBubbleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circular skeleton
          SkeletonBox(
            width: AppSizing.avatarSm,
            height: AppSizing.avatarSm,
            borderRadius: AppSizing.radiusCircular,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: AppSizing.skeletonLabelWidth,
                  height: AppSizing.skeletonLineHeight,
                ),
                SizedBox(height: AppSpacing.xxs),
                SkeletonBox(height: AppSizing.skeletonLineHeight),
                SizedBox(height: AppSpacing.xxs),
                SkeletonBox(
                  width: AppSizing.skeletonTextWidth,
                  height: AppSizing.skeletonLineHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
