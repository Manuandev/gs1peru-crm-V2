// lib/features/cobranza/presentation/widgets/lista/cobranza_list_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListView extends StatelessWidget {
  const CobranzaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goToHome(),
      bodyPadding: EdgeInsets.zero,
      title: 'Cobranzas',
      drawerSide: DrawerSide.left,
      showBottomNav: true,
      // Buscador (nombre, empresa, celular, N° de solicitud): llega en cada
      // tecla, el bloc hace el debounce y el filtro lo aplica el SP (la lista
      // es paginada).
      onSearch: (query) => context.read<CobranzaListBloc>().add(
        CobranzaBusquedaCambiada(query),
      ),
      // Botón de filtro avanzado (abre el endDrawer derecho) — naranja solo si
      // el asesor cambió el filtro respecto al default (mes actual → hoy).
      appBarTrailingButtons: [
        BlocBuilder<CobranzaListBloc, CobranzaListState>(
          buildWhen: (prev, curr) {
            final p = prev is CobranzaListCargado && prev.tieneFiltroAvanzado;
            final c = curr is CobranzaListCargado && curr.tieneFiltroAvanzado;
            return p != c;
          },
          builder: (context, state) {
            final tieneAvanzado =
                state is CobranzaListCargado && state.tieneFiltroAvanzado;
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
      endDrawerWidget: const CobranzaFiltroDrawer(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          final bloc = context.read<CobranzaListBloc>();
          bloc.add(const CobranzaListRefresh());
          await bloc.stream.firstWhere(
            (s) => s is CobranzaListCargado || s is CobranzaListErrorInicial,
          );
        },
        child: BlocBuilder<CobranzaListBloc, CobranzaListState>(
          builder: (context, state) {
            return switch (state) {
              CobranzaListInitial() ||
              CobranzaListCargando() => const AppLoadingView(),
              CobranzaListErrorInicial(:final mensaje) => AppErrorView(
                message: mensaje,
                onRetry: () => context.read<CobranzaListBloc>().add(
                  const CobranzaListRefresh(),
                ),
              ),
              CobranzaListCargado() => CobranzaListPortrait(estado: state),
            };
          },
        ),
      ),
    );
  }
}
