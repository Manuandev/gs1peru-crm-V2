// lib/features/home/presentation/widgets/home_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      title: 'Notificaciones',
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],
      appBarTrailingButtons: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
          onPressed: () {
            context.read<NotificationsBloc>().add(NotificationsRefresh());
          },
        ),
      ],
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsInitial || state is NotificationsLoading) {
            return const AppLoadingView();
          }

          if (state is NotificationsError) {
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<NotificationsBloc>().add(NotificationsRefresh()),
            );
          }

          if (state is NotificationsLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return NotificationsPortrait(state: state);
                  // return NotificationsLandscape(state: state);
                }
                return NotificationsPortrait(state: state);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
