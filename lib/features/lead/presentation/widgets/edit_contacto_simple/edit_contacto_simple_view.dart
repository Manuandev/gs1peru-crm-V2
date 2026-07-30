// lib/features/lead/presentation/widgets/edit_contacto_simple/edit_contacto_simple_view.dart
//
// Título dinámico según si el contacto ya existe (idContacto != 0 → "Editar
// contacto") o todavía no (idContacto == 0 → "Editar número") — mismo
// patrón que EditContactoView (pantalla completa).

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoSimpleView extends StatefulWidget {
  final int idNumero;

  const EditContactoSimpleView({super.key, required this.idNumero});

  @override
  State<EditContactoSimpleView> createState() =>
      _EditContactoSimpleViewState();
}

class _EditContactoSimpleViewState extends State<EditContactoSimpleView> {
  final ValueNotifier<bool> _guardando = ValueNotifier(false);

  @override
  void dispose() {
    _guardando.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      titleWidget:
          BlocBuilder<ContactoSimpleFormCubit, ContactoSimpleFormState>(
        buildWhen: (prev, curr) => curr is ContactoSimpleFormSuccess,
        builder: (context, state) {
          final titulo =
              state is ContactoSimpleFormSuccess && state.contacto.idContacto != 0
              ? 'Editar contacto'
              : 'Editar contacto';
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
      body: BlocBuilder<ContactoSimpleFormCubit, ContactoSimpleFormState>(
        builder: (context, state) {
          if (state is ContactoSimpleFormInitial ||
              state is ContactoSimpleFormLoading) {
            return const AppLoadingView();
          }
          if (state is ContactoSimpleFormFailure) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context
                  .read<ContactoSimpleFormCubit>()
                  .cargarPorIdNumero(widget.idNumero),
            );
          }
          if (state is! ContactoSimpleFormSuccess) return const AppLoadingView();

          return EditContactoSimplePortrait(
            key: ValueKey(state.contacto.idContacto),
            contacto: state.contacto,
            guardandoNotifier: _guardando,
          );
        },
      ),
    );
  }
}
