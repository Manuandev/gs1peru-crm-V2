// lib/features/lead/presentation/widgets/seguimiento/seguimiento_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoView extends StatelessWidget {
  const SeguimientoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goToHome(),
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Seguimiento',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          Text(
            'Gestiona el avance de tus casos',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white(0.75),
            ),
          ),
        ],
      ),
      drawerSide: DrawerSide.left,
      bodyPadding: EdgeInsets.zero,
      // Botón de filtro avanzado (abre el endDrawer derecho).
      appBarTrailingButtons: [
        BlocBuilder<SeguimientoBloc, SeguimientoEstado>(
          buildWhen: (prev, curr) {
            final prevHas =
                prev is SeguimientoCargado && prev.tieneFiltroAvanzado;
            final currHas =
                curr is SeguimientoCargado && curr.tieneFiltroAvanzado;
            return prevHas != currHas;
          },
          builder: (context, state) {
            final tieneAvanzado =
                state is SeguimientoCargado && state.tieneFiltroAvanzado;
            return Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Filtrar',
                icon: Icon(
                  AppIcons.filter,
                  color: tieneAvanzado
                      ? AppColors.secondary
                      : AppColors.textOnDark,
                ),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            );
          },
        ),
      ],
      endDrawerWidget: const SeguimientoFiltroDrawer(),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                final bloc = context.read<SeguimientoBloc>();
                bloc.add(const SeguimientoRefrescado());
                await bloc.stream.firstWhere(
                  (s) =>
                      s is SeguimientoCargado || s is SeguimientoErrorInicial,
                );
              },
              child: BlocBuilder<SeguimientoBloc, SeguimientoEstado>(
                builder: (context, state) {
                  return switch (state) {
                    SeguimientoInicial() ||
                    SeguimientoCargando() => const LeadListSkeleton(),
                    SeguimientoErrorInicial(:final mensaje) => AppErrorView(
                      message: mensaje,
                      onRetry: () => context.read<SeguimientoBloc>().add(
                        const SeguimientoRefrescado(),
                      ),
                    ),
                    SeguimientoCargado() => SeguimientoPortrait(estado: state),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
