// lib/features/lead/presentation/pages/edit_lead_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadPage extends StatelessWidget {
  final int idLead;
  // true cuando la negociación ya tiene solicitud generada (numSol) — se
  // reusa esta misma pantalla para mostrar sus datos, pero sin permitir
  // ningún cambio (ver NegociacionCard._verNegociacion).
  final bool soloLectura;
  // true cuando se entra desde el chat de Conversaciones (ChatDetailView) —
  // oculta Información adicional y restringe Estado/Canal/Campaña/Oportunidad
  // (ver EditLeadPortrait).
  final bool desdeConversacion;
  const EditLeadPage({
    super.key,
    required this.idLead,
    this.soloLectura = false,
    this.desdeConversacion = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditLeadBloc()..add(const EditLeadStarted()),
      child: EditLeadView(
        soloLectura: soloLectura,
        desdeConversacion: desdeConversacion,
      ),
    );
  }
}
