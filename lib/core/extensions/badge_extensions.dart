// lib/core/extensions/badge_extensions.dart

import 'package:app_crm/core/presentation/bloc/drawer/drawer_bloc.dart';
import 'package:app_crm/core/presentation/bloc/drawer/drawer_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BadgeExtension on BuildContext {
  void updateBadge({int? leads, int? recordatorios, int? chats}) {
    read<DrawerBloc>().add(
      DrawerBadgesUpdated(
        newLeads: leads,
        pendingRecordatorios: recordatorios,
        unreadChats: chats,
      ),
    );
  }
}
