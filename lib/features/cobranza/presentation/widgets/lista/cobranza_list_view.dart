// lib/features/cobranza/presentation/widgets/cobranza_list_view.dart

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
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
          onPressed: () =>
              context.read<CobranzaListBloc>().add(const CobranzaListRefresh()),
        ),
      ],
      body: BlocBuilder<CobranzaListBloc, CobranzaListState>(
        builder: (context, state) {
          if (state is CobranzaListLoading || state is CobranzaListInitial) {
            return const Center(child: CircularProgressIndicator());
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
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
