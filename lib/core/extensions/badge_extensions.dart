// lib/core/extensions/badge_extensions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

extension BadgeExtension on BuildContext {
  void updateBadge({
    int? conversaciones,
    int? prospectos,
    int? propuestas,
    int? cobranza,
  }) {
    read<DrawerBloc>().add(
      DrawerBadgesUpdated(
        conversaciones: conversaciones,
        prospectos: prospectos,
        propuestas: propuestas,
        cobranza: cobranza,
        // newLead: leads,
        // pendingReminders: reminders,
        // unreadChats: chats,
      ),
    );
  }
}
