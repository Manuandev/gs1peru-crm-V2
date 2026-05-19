// lib/core/extensions/badge_extensions.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BadgeExtension on BuildContext {
  void updateBadge({int? conversaciones, int? prospectos, int? propuestas, int? cobranzas}) {
    read<DrawerBloc>().add(
      DrawerBadgesUpdated(
        conversaciones: conversaciones,
        prospectos: prospectos,
        propuestas: propuestas,
        cobranzas: cobranzas,
        // newLead: leads,
        // pendingReminders: reminders,
        // unreadChats: chats,
      ),
    );
  }
}
