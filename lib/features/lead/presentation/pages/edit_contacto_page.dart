// lib/features/lead/presentation/pages/edit_contacto_page.dart
//
// Recibe SOLO idNumero — al entrar, ContactoFormCubit carga los datos del
// contacto (si ya existe) para ese número. Ver EditContactoView para el
// título dinámico según si el contacto ya existe.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoPage extends StatelessWidget {
  final int idNumero;

  const EditContactoPage({super.key, required this.idNumero});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ContactoFormCubit(ctx.read<LeadRepository>())
        ..cargarPorIdNumero(idNumero),
      child: EditContactoView(idNumero: idNumero),
    );
  }
}
