// lib/features/lead/presentation/widgets/edit_lead/edit_lead_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadView extends StatefulWidget {
  final bool soloLectura;
  final bool desdeConversacion;
  const EditLeadView({
    super.key,
    this.soloLectura = false,
    this.desdeConversacion = false,
  });

  @override
  State<EditLeadView> createState() => _EditLeadViewState();
}

class _EditLeadViewState extends State<EditLeadView> {
  final List<StreamSubscription<String>> _subs = [];
  // Espejo de _isLoading/_mostrandoExito de EditLeadPortrait — bloquea el
  // back del AppBar mientras se guarda/muestra el check de éxito, para que
  // el usuario no dispare un pop manual que compita con el pop automático
  // de _guardar() (bug real: eso dejaba la pantalla varada en "Editar
  // negociación" y, entrando desde Conversación, cerraba de encima el
  // ChatLeadPanel al volver antes de tiempo).
  final ValueNotifier<bool> _guardando = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InfoLeadCubit>();
    // Éxito ya no se muestra acá con un snackbar — EditLeadPortrait._guardar()
    // muestra su propio check verde grande y retrocede solo (ver
    // _ExitoOverlay), un snackbar duplicado se vería encima justo cuando la
    // pantalla ya está por cerrarse. Los errores sí se quedan acá — no
    // navegan a ningún lado, el usuario se queda en el form para corregir.
    _subs.addAll([
      // ignore: use_build_context_synchronously
      cubit.errores.listen((msg) => AppSnackBar.error(context, msg)),
    ]);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _guardando.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      titleWidget: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        buildWhen: (prev, curr) => curr is InfoLeadSuccess,
        builder: (context, state) {
          final esNuevo =
              state is InfoLeadSuccess && state.negociacion.idLead == 0;
          final titulo = widget.soloLectura
              ? 'Ver negociación'
              : (esNuevo ? 'Crear negociación' : 'Editar negociación');
          return Text(
            titulo,
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        },
      ),
      bodyPadding: EdgeInsets.zero,
      drawerSide: DrawerSide.none,
      appBarLeadingButtons: [
        ValueListenableBuilder<bool>(
          valueListenable: _guardando,
          builder: (context, guardando, _) => IconButton(
            icon: const Icon(AppIcons.backIos),
            onPressed: guardando ? null : () => context.goBack(),
          ),
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
                  soloLectura: widget.soloLectura,
                  desdeConversacion: widget.desdeConversacion,
                  guardandoNotifier: _guardando,
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
