// lib/features/lead/presentation/pages/contacto_detalle_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetallePage extends StatelessWidget {
  final int idContacto;
  final int idLead;

  const ContactoDetallePage({
    super.key,
    required this.idContacto,
    required this.idLead,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactoDetalleBloc(
        obtenerDetalle: ObtenerDetalleContactoUseCase(
          context.read<LeadRepository>(),
        ),
        obtenerNegociaciones: GetNegociacionesLead(
          context.read<LeadRepository>(),
        ),
      )..add(ContactoDetalleStarted(idContacto, idLead)),
      child: ContactoDetalleView(idContacto: idContacto, idLead: idLead),
    );
  }
}
