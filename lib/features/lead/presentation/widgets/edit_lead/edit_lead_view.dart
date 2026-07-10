// lib/features/chat/presentation/widgets/edit_lead/edit_lead_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadView extends StatefulWidget {
  const EditLeadView({super.key});

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
      titleWidget: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        buildWhen: (prev, curr) => curr is InfoLeadSuccess,
        builder: (context, state) {
          final esNuevo = state is InfoLeadSuccess && state.negociacion.idLead == 0;
          return Text(
            esNuevo ? 'Crear negociación' : 'Editar negociación',
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        },
      ),
      bodyPadding: EdgeInsets.zero,
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(AppIcons.backIos),
          onPressed: () => context.goBack(),
        ),
      ],
      body: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        builder: (context, infoState) {
          if (infoState is InfoLeadLoading || infoState is InfoLeadInitial) {
            return const AppLoadingView();
          }
          if (infoState is InfoLeadFailure) {
            return AppErrorView(
              message: infoState.message,
              onRetry: () => context.goBack(),
            );
          }
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
                  negociacion: infoState.negociacion, // ← del cubit
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
