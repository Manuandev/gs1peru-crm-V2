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
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                final bloc = context.read<LeadListBloc>();
                bloc.add(const LeadListRefresh());
                await bloc.stream.firstWhere(
                  (s) => s is LeadListSuccess || s is LeadListError,
                );
              },
              child: BlocBuilder<LeadListBloc, LeadListState>(
                builder: (context, state) {
                  if (state is LeadListLoading || state is LeadListInitial) {
                    return const LeadListSkeleton();
                  }

                  if (state is LeadListError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<LeadListBloc>().add(
                        const LeadListRefresh(),
                      ),
                    );
                  }

                  if (state is LeadListSuccess) {
                    return LeadListPortrait(
                      leads: state.contactos,
                      filtro: state.filtro,
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
