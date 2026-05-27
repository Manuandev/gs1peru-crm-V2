// lib\features\reminder\presentation\pages\reminder_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';

class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReminderListBloc(
        GetRemindersUseCase(ReminderRepositoryImpl(ReminderRemoteDatasource())),
      )..add(const ReminderListStarted()),
      child: BlocListener<ReminderListBloc, ReminderListState>(
        listener: (context, state) {
          if (state is ReminderListError) {
            context.showErrorSnack(state.message);
          } else if (state is ReminderListLoaded) {
            // context.updateBadge(reminders: state.reminders.length);
          }
        },
        child: const ReminderListView(),
      ),
    );
  }
}
