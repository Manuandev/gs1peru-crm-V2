// lib/features/lead/presentation/pages/edit_contacto_simple_page.dart
//
// Recibe SOLO idContacto (migrado de idNumero 2026-08-03, ver
// lead/CLAUDE.md) — al entrar, ContactoSimpleFormCubit carga los datos
// reducidos del contacto (si ya existe) para ese id. Pantalla alterna
// a EditContactoPage (pantalla completa, que sigue existiendo intacta),
// pedido de negocio 2026-07-27 — ver lead/CLAUDE.md.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditContactoSimplePage extends StatelessWidget {
  final int idContacto;

  const EditContactoSimplePage({super.key, required this.idContacto});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ContactoSimpleFormCubit(ctx.read<LeadRepository>())
        ..cargarPorIdContacto(idContacto),
      child: EditContactoSimpleView(idContacto: idContacto),
    );
  }
}
