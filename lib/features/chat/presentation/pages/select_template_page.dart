// lib\features\home\presentation\pages\notificaciones_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

class SelectTemplatePage extends StatelessWidget {
  final InfoLead lead;

  const SelectTemplatePage({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectTemplateBloc(
        getData: GetTemplatesUseCase(context.read<ChatRepository>()),
      )..add(const SelectTemplateStarted()),
      child: BlocListener<SelectTemplateBloc, SelectTemplateState>(
        listener: (context, state) {},
        child: SelectTemplateView(lead: lead),
      ),
    );
  }
}
