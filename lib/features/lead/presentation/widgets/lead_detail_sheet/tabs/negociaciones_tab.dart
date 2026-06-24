// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/negociaciones_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/presentation/cubit/negociaciones/negociaciones_cubit.dart';
import 'package:app_crm/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart';

class NegociacionesTab extends StatefulWidget {
  final int leadId;

  const NegociacionesTab({super.key, required this.leadId});

  @override
  State<NegociacionesTab> createState() => _NegociacionesTabState();
}

class _NegociacionesTabState extends State<NegociacionesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<NegociacionesCubit>().cargarNegociaciones(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<NegociacionesCubit, NegociacionesState>(
      builder: (context, state) {
        return switch (state) {
          NegociacionesInitial() || NegociacionesLoading() =>
            const AppLoadingView(),
          NegociacionesError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: () => context
                .read<NegociacionesCubit>()
                .cargarNegociaciones(widget.leadId),
          ),
          NegociacionesSuccess(:final negociaciones) => _ListaNegociaciones(
            negociaciones: negociaciones,
          ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista con header + cards + info banner
// ─────────────────────────────────────────────────────────────────────────────

class _ListaNegociaciones extends StatelessWidget {
  final List<NegociacionFake> negociaciones;

  const _ListaNegociaciones({required this.negociaciones});

  @override
  Widget build(BuildContext context) {
    if (negociaciones.isEmpty) {
      return const _EstadoVacio();
    }

    final seleccionada = negociaciones
        .where((n) => n.accion == AccionNegociacion.seleccionada)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        // ── Header de conteos ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            '${seleccionada > 0 ? '1 conversación' : '0 conversaciones'} • ${negociaciones.length} negociaciones',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // ── Cards ──────────────────────────────────────────────────────────
        ...negociaciones.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: NegociacionCard(negociacion: n),
          ),
        ),

        // ── Info banner ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.infoCircle,
                size: AppSizing.iconSm,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'La negociación seleccionada es la que se utiliza para actualizar el CRM y, en su caso, cerrar como ganada para generar una solicitud.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de negociación
// ─────────────────────────────────────────────────────────────────────────────

class NegociacionCard extends StatelessWidget {
  final NegociacionFake negociacion;

  const NegociacionCard({super.key, required this.negociacion});

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppIconsSocial.colorEstado(negociacion.idEstado);
    final bgEstado = AppIconsSocial.bgEstado(negociacion.idEstado);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurXs,
            offset: Offset(0, AppSizing.shadowOffsetCardY),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ícono del curso/evento ───────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgEstado,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(
              AppIcons.interes,
              size: AppSizing.iconMd,
              color: colorEstado,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Contenido ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  negociacion.nombre,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
                Text(
                  negociacion.empresa,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppIconsSocial.chipEstado(
                  negociacion.idEstado,
                  label: negociacion.estado,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    AppIconsSocial.widgetCanal(
                      negociacion.idCanal,
                      size: AppSizing.iconXs,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'Canal',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      AppIcons.users,
                      size: AppSizing.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${negociacion.cantidad} ${negociacion.cantidad == 1 ? 'persona' : 'personas'}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      AppIcons.calendar,
                      size: AppSizing.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      negociacion.ultimaActualizacion,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Botón de acción ─────────────────────────────────────────────
          _AccionWidget(accion: negociacion.accion, colorEstado: colorEstado),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget de acción según estado de la negociación
// ─────────────────────────────────────────────────────────────────────────────

class _AccionWidget extends StatelessWidget {
  final AccionNegociacion accion;
  final Color colorEstado;

  const _AccionWidget({required this.accion, required this.colorEstado});

  @override
  Widget build(BuildContext context) {
    return switch (accion) {
      AccionNegociacion.seleccionada => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(
              AppIcons.check,
              color: AppColors.textOnDark,
              size: AppSizing.iconMd,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Seleccionada',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
      AccionNegociacion.verPropuesta => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: AppSizing.buttonHeightSmall,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                textStyle: AppTextStyles.labelSmall,
              ),
              child: const Text('Ver propuesta'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: AppSizing.buttonHeightSmall,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                textStyle: AppTextStyles.labelSmall,
              ),
              child: const Text('Seleccionar'),
            ),
          ),
        ],
      ),
      AccionNegociacion.generarSolicitud => SizedBox(
        width: 80,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textOnDark,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.fileFactura, size: AppSizing.iconActionSm),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Generar\nsolicitud',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSizing.radiusXl),
              ),
              child: const Icon(
                Icons.handshake_outlined,
                size: AppSizing.iconXl,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin negociaciones',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Este lead aún no tiene negociaciones registradas.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
