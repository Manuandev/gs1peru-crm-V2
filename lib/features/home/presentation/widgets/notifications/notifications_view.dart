// lib/features/home/presentation/widgets/notifications/notifications_view.dart

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
      titleWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificaciones',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            'Actividades, derivaciones del bot y nuevos mensajes',
            style: AppTextStyles.labelSmall.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(AppIcons.backIos),
          onPressed: () => context.goBack(),
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          final bloc = context.read<NotificationsBloc>();
          bloc.add(const NotificationsRefresh());
          // Ojo: al recargar con la lista ya visible, el bloc emite primero un
          // NotificationsLoaded con recargandoLista:true (para no tumbar la
          // pantalla). Hay que esperar al que trae la data, si no el spinner
          // del RefreshIndicator se cierra de una.
          await bloc.stream.firstWhere(
            (s) =>
                (s is NotificationsLoaded && !s.recargandoLista) ||
                s is NotificationsError,
          );
        },
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsInitial ||
                state is NotificationsLoading) {
              return const AppLoadingView();
            }

            if (state is NotificationsError) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<NotificationsBloc>().add(
                  NotificationsRefresh(),
                ),
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
      ),
    );
  }
}
