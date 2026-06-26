// lib/features/solicitudes/presentation/widgets/list/solicitud_list_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListView extends StatelessWidget {
  const SolicitudListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goToHome(),
      title: 'Solicitudes',
      drawerSide: DrawerSide.left,
      bodyPadding: EdgeInsets.zero,
      onSearch: (query) {
        context.read<SolicitudListBloc>().add(SolicitudListSearched(query));
      },
      body: Column(
        children: [
          // ── Header azul — siempre visible, no espera datos ────
          const _SolicitudHeader(),

          // ── Contenido scrollable con pull-to-refresh ──────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                final bloc = context.read<SolicitudListBloc>();
                bloc.add(const SolicitudListRefresh());
                await bloc.stream.firstWhere(
                  (s) => s is SolicitudListSuccess || s is SolicitudListError,
                );
              },
              child: BlocBuilder<SolicitudListBloc, SolicitudListState>(
                builder: (context, state) {
                  if (state is SolicitudListLoading ||
                      state is SolicitudListInitial) {
                    return const SolicitudListSkeleton();
                  }

                  if (state is SolicitudListError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<SolicitudListBloc>().add(
                        const SolicitudListRefresh(),
                      ),
                    );
                  }

                  if (state is SolicitudListSuccess) {
                    return Column(
                      children: [
                        // Indicadores superpuestos sobre el header
                        Transform.translate(
                          offset: const Offset(0, -AppSpacing.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: _IndicadoresRow(state: state),
                          ),
                        ),

                        // ── Tabs de filtro + lista ──────────────
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -AppSpacing.md),
                            child: SolicitudListPortrait(
                              solicitudes: state.solicitudes,
                              filtro: state.filtro,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header azul — siempre visible ────────────────────────────────────────────

class _SolicitudHeader extends StatelessWidget {
  const _SolicitudHeader();

  @override
  Widget build(BuildContext context) {
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
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Text(
        ' Solicitudes pendientes por completar y validar',
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textOnDark,
          fontWeight: AppTextStyles.weightRegular,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ─── Fila de indicadores tipo dashboard ──────────────────────────────────────

class _IndicadoresRow extends StatelessWidget {
  final SolicitudListSuccess state;

  const _IndicadoresRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _IndicadorItem(
                icono: Icons.assignment_outlined,
                label: 'Por\ncompletar',
                conteo: state.cntPorCompletar,
                color: AppColors.info,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _IndicadorItem(
                icono: Icons.access_time_outlined,
                label: 'Por\nvalidar',
                conteo: state.cntPorValidar,
                color: AppColors.warning,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _IndicadorItem(
                icono: Icons.description_outlined,
                label: 'Con\ndocumentos',
                conteo: state.cntConDocumentos,
                color: AppColors.success,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _IndicadorItem(
                icono: Icons.monetization_on_outlined,
                label: 'Listas para\ncobranza',
                conteo: state.cntListasCobranza,
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadorItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final int conteo;
  final Color color;

  const _IndicadorItem({
    required this.icono,
    required this.label,
    required this.conteo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono con fondo suave — contenedor cuadrado redondeado
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
            ),
            child: Icon(icono, size: 20, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Label — máx 2 líneas, texto pequeño centrado
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Conteo resaltado
          Text(
            '$conteo',
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Container(width: 1, color: AppColors.border),
    );
  }
}
