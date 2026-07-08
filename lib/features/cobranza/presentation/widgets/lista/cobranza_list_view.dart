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
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          final bloc = context.read<CobranzaListBloc>();
          bloc.add(const CobranzaListRefresh());
          await bloc.stream.firstWhere(
            (s) => s is CobranzaListSuccess || s is CobranzaListError,
          );
        },
        child: BlocBuilder<CobranzaListBloc, CobranzaListState>(
          builder: (context, state) {
            if (state is CobranzaListLoading || state is CobranzaListInitial) {
              return const AppLoadingView();
            }

            if (state is CobranzaListError) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<CobranzaListBloc>().add(
                  const CobranzaListRefresh(),
                ),
              );
            }

            if (state is CobranzaListSuccess) {
              return Column(
                children: [
                  CobranzaSummaryCards(
                    conteosPorEstado: state.conteosPorEstado,
                    estadosSeleccionados: state.estadosSeleccionados,
                    onEstadoTap: (idEstado) => context
                        .read<CobranzaListBloc>()
                        .add(CobranzaEstadoToggled(idEstado)),
                  ),
                  Expanded(
                    child: CobranzaListPortrait(
                      cobranzas: state.cobranzas,
                      chipFiltro: state.chipFiltro,
                      estadosSeleccionados: state.estadosSeleccionados,
                      asesorSeleccionado: state.asesorSeleccionado,
                      conteosPorAsesor: state.conteosPorAsesor,
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
