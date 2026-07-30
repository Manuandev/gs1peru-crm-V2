// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_view.dart
//
// Título dinámico según si el contacto ya existe (idContacto != 0 → "Editar
// contacto") o todavía no (idContacto == 0 → "Editar número") — pedido
// explícito del usuario. Mismo patrón de guardandoNotifier que EditLeadView
// (lead/edit_lead) para bloquear el back del AppBar mientras se guarda.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoView extends StatefulWidget {
  final int idNumero;

  const EditContactoView({super.key, required this.idNumero});

  @override
  State<EditContactoView> createState() => _EditContactoViewState();
}

class _EditContactoViewState extends State<EditContactoView> {
  final ValueNotifier<bool> _guardando = ValueNotifier(false);

  @override
  void dispose() {
    _guardando.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      titleWidget: BlocBuilder<ContactoFormCubit, ContactoFormState>(
        buildWhen: (prev, curr) => curr is ContactoFormSuccess,
        builder: (context, state) {
          final titulo = state is ContactoFormSuccess && state.contacto.idContacto != 0
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
      body: BlocBuilder<ContactoFormCubit, ContactoFormState>(
        builder: (context, state) {
          if (state is ContactoFormInitial || state is ContactoFormLoading) {
            return const AppLoadingView();
          }
          if (state is ContactoFormFailure) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<ContactoFormCubit>().cargarPorIdNumero(
                widget.idNumero,
              ),
            );
          }
          if (state is! ContactoFormSuccess) return const AppLoadingView();

          return EditContactoPortrait(
            key: ValueKey(state.contacto.idContacto),
            contacto: state.contacto,
            guardandoNotifier: _guardando,
          );
        },
      ),
    );
  }
}
