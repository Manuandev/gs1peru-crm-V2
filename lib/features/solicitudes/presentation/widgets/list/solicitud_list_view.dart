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
      body: RefreshIndicator(
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
                  // ── Indicadores tipo dashboard ──────────────────
                  _IndicadoresRow(state: state),

                  // ── Tabs de filtro + lista ──────────────────────
                  Expanded(
                    child: SolicitudListPortrait(
                      solicitudes: state.solicitudes,
                      filtro: state.filtro,
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
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
      margin: const EdgeInsets.all(AppSpacing.md),
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
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
    return Container(width: 1, color: AppColors.border);
  }
}
