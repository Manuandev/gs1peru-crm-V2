// lib/features/chat/presentation/widgets/chat_detail/template/select_template_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class SelectTemplateView extends StatefulWidget {
  final InfoLead lead;

  const SelectTemplateView({super.key, required this.lead});

  @override
  State<SelectTemplateView> createState() => _SelectTemplateViewState();
}

class _SelectTemplateViewState extends State<SelectTemplateView> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Seleccionar plantilla',
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],

      body: BlocBuilder<SelectTemplateBloc, SelectTemplateState>(
        builder: (context, state) {
          if (state is SelectTemplateInitial ||
              state is SelectTemplateLoading) {
            return const AppLoadingView();
          }

          if (state is SelectTemplateError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<SelectTemplateBloc>().add(
                SelectTemplateRefresh(),
              ),
            );
          }

          if (state is SelectTemplateLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return SelectTemplatePortrait(state: state);
                }
                return SelectTemplatePortrait(state: state);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
