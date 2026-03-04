// lib/core/extensions/badge_extensions.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BadgeExtension on BuildContext {
  void updateBadge({int? leads, int? reminders, int? chats}) {
    read<DrawerBloc>().add(
      DrawerBadgesUpdated(
        newLeads: leads,
        pendingReminders: reminders,
        unreadChats: chats,
      ),
    );
  }
}
