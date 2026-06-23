// lib/features/lead/presentation/widgets/list/lead_list_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListView extends StatelessWidget {
  const LeadListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadListVistaCubit, bool>(
      builder: (context, modoCompacto) {
        return BasePage(
          onPop: () => context.goToHome(),
          title: 'Seguimientos',
          drawerSide: DrawerSide.left,
          appBarTrailingButtons: [
            IconButton(
              icon: Icon(
                modoCompacto ? AppIcons.vistaDetallada : AppIcons.vistaCompacta,
                color: AppColors.textOnDark,
              ),
              tooltip: modoCompacto ? 'Vista detallada' : 'Vista compacta',
              onPressed: () =>
                  context.read<LeadListVistaCubit>().alternar(),
            ),
            IconButton(
              icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
              onPressed: () =>
                  context.read<LeadListBloc>().add(const LeadListRefresh()),
            ),
          ],
          body: BlocBuilder<LeadListBloc, LeadListState>(
            builder: (context, state) {
              if (state is LeadListLoading || state is LeadListInitial) {
                return const LeadListSkeleton();
              }

              if (state is LeadListError) {
                return AppErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<LeadListBloc>().add(const LeadListRefresh()),
                );
              }

              if (state is LeadListSuccess) {
                return LeadListPortrait(
                  leads: state.leads,
                  filtro: state.filtro,
                  modoCompacto: modoCompacto,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
