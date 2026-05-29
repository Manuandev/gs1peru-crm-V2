// lib\features\home\presentation\pages\notificaciones_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(
        //   create: (_) => NotificationsBloc(
        //     GetNotificationUseCase(context.read<NotificationsRepository>()),
        //     SendNotificationUseCase(context.read<NotificationsRepository>()),
        //     SendFileNotificationUseCase(
        //       context.read<NotificationsRepository>(),
        //     ),
        //   )..add(NotificationStarted()),
        // ),
        // BlocProvider(
        //   create: (_) =>
        //       InfoLeadCubit(GetInfoUseCase(context.read<ChatRepository>())),
        // ),
      ],
      child: Text('NotificationsPage'),
    );
  }
}
