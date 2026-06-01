// lib/features/chat/presentation/widgets/templates/templates_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadView extends StatefulWidget {
  final InfoLead lead;
  const EditLeadView({super.key, required this.lead});

  @override
  State<EditLeadView> createState() => _EditLeadViewState();
}

class _EditLeadViewState extends State<EditLeadView> {
  final List<StreamSubscription<String>> _subs = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InfoLeadCubit>();
    _subs.addAll([
      cubit.successes.listen(
        // ignore: use_build_context_synchronously
        (msg) => AppSnackBar.success(context, msg, position: SnackPosition.top),
      ),
      // ignore: use_build_context_synchronously
      cubit.errores.listen((msg) => AppSnackBar.error(context, msg)),
    ]);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

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
      body: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        builder: (context, infoState) {
          if (infoState is! InfoLeadSuccess) return const AppLoadingView();

          return BlocBuilder<EditLeadBloc, EditLeadState>(
            builder: (context, state) {
              if (state is EditLeadInitial || state is EditLeadLoading) {
                return const AppLoadingView();
              }
              if (state is EditLeadError) {
                return AppErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<EditLeadBloc>().add(EditLeadRefresh()),
                );
              }
              if (state is EditLeadLoaded) {
                return EditLeadPortrait(
                  lead: infoState.infoLead,
                ); // ← del cubit
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
