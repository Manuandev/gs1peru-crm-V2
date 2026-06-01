// lib/features/chat/presentation/widgets/templates/templates_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class TemplatesView extends StatelessWidget {
  const TemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Editar lead',
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],
      body: BlocBuilder<TemplatesBloc, TemplatesState>(
        builder: (context, state) {
          if (state is TemplatesInitial || state is TemplatesLoading) {
            return const AppLoadingView();
          }

          if (state is TemplatesError) {
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<TemplatesBloc>().add(TemplatesRefresh()),
            );
          }

          if (state is TemplatesLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return TemplatesPortrait();
                }
                return TemplatesPortrait();
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
