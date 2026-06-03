// lib\features\lead\presentation\widgets\lead_list_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListView extends StatelessWidget {
  final LeadType type;

  const LeadListView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goToHome(),
      title: type == LeadType.seguimientos ? 'Prospectos' : 'Propuestas',
      drawerSide: DrawerSide.left,
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
          onPressed: () {
            context.read<LeadListBloc>().add(LeadListRefresh(type));
          },
        ),
      ],
      body: BlocBuilder<LeadListBloc, LeadListState>(
        builder: (context, state) {
          if (state is LeadListLoading || state is LeadListInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeadListError) {
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<LeadListBloc>().add(LeadListRefresh(type)),
            );
          }

          if (state is LeadListSuccess) {
            if (state.leads.isEmpty) {
              return AppEmptyView(
                message: type == LeadType.seguimientos
                    ? 'No hay seguimientos.'
                    : 'No hay propuestas.',
              );
            }
            return LeadListPortrait(leads: state.leads);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
