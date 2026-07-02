// lib/features/lead/presentation/pages/contacto_detalle_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetallePage extends StatelessWidget {
  final int idLead;

  const ContactoDetallePage({super.key, required this.idLead});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => InfoLeadCubit(
            GetInfoUseCase(context.read<ChatRepository>()),
            UpdateLeadEstadoUseCase(context.read<ChatRepository>()),
            UpdateLeadInfoUseCase(context.read<LeadRepository>()),
          ),
        ),
        BlocProvider(
          create: (_) => NegociacionesCubit(
            obtenerNegociacionesUseCase:
                GetNegociacionesLead(context.read<LeadRepository>()),
          ),
        ),
        BlocProvider(
          create: (_) => HistorialLeadCubit(
            obtenerHistorialUseCase:
                GetHistorialComentarios(context.read<LeadRepository>()),
          ),
        ),
      ],
      child: ContactoDetalleView(idLead: idLead),
    );
  }
}
