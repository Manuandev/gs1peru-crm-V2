// lib\features\home\presentation\pages\notificaciones_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TemplatesBloc()..add(const TemplatesStarted()),
      child: BlocListener<TemplatesBloc, TemplatesState>(
        listener: (context, state) {
          if (state is TemplatesError) {
          } else if (state is TemplatesLoaded) {}
        },
        child: const TemplatesView(),
      ),
    );
  }
}
