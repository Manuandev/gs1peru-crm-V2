// lib/features/lead/presentation/pages/lead_detalle_page.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetallePage extends StatelessWidget {
  final int idLead;

  const LeadDetallePage({super.key, required this.idLead});

  @override
  Widget build(BuildContext context) {
    // TODO: Esto es un puente temporal. Reusa InfoLeadCubit/InfoLead del
    // feature chat porque edit_lead_page propio del feature lead todavía
    // está incompleto (sus imports apuntan a chat). Cuando ese feature
    // esté terminado, lead_detalle debe usar su propio Lead/LeadDetalleBloc
    // para editar, sin depender de ChatRepository.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => InfoLeadCubit(
            GetInfoUseCase(ctx.read<ChatRepository>()),
            UpdateLeadEstadoUseCase(ctx.read<ChatRepository>()),
            UpdateLeadInfoUseCase(ctx.read<LeadRepository>()),
            GetLeadDetalleUseCase(ctx.read<LeadRepository>()),
          )..cargarPorIdLead(idLead),
        ),
        BlocProvider(
          create: (ctx) => LeadDetalleBloc(
            GetLeadDetalleUseCase(ctx.read<LeadRepository>()),
          )..add(LeadDetalleStarted(idLead)),
        ),
      ],
      child: LeadDetalleView(idLead: idLead),
    );
  }
}
