// lib/features/lead/presentation/pages/edit_contacto_simple_page.dart
//
// Recibe SOLO idNumero — al entrar, ContactoSimpleFormCubit carga los datos
// reducidos del contacto (si ya existe) para ese número. Pantalla alterna
// a EditContactoPage (pantalla completa, que sigue existiendo intacta),
// pedido de negocio 2026-07-27 — ver lead/CLAUDE.md.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoSimplePage extends StatelessWidget {
  final int idNumero;

  const EditContactoSimplePage({super.key, required this.idNumero});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ContactoSimpleFormCubit(ctx.read<LeadRepository>())
        ..cargarPorIdNumero(idNumero),
      child: EditContactoSimpleView(idNumero: idNumero),
    );
  }
}
