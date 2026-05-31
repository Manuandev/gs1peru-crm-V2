// lib\features\home\presentation\pages\notificaciones_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
            NotificationsBloc(getData: GetNotificationsUseCase(context.read<HomeRepository>()))
              ..add(const NotificationsStarted()),
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsError) {
          } else if (state is NotificationsLoaded) {
          }
        },
        child: const NotificationsView(),
      ),
    );
  }
}
