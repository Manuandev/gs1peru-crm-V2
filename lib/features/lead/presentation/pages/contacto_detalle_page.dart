// lib/features/lead/presentation/pages/contacto_detalle_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetallePage extends StatelessWidget {
  final int idNumero;

  const ContactoDetallePage({super.key, required this.idNumero});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => InfoLeadCubit(
            GetInfoUseCase(context.read<ChatRepository>()),
            UpdateLeadEstadoUseCase(context.read<ChatRepository>()),
            UpdateLeadInfoUseCase(context.read<LeadRepository>()),
            // null: cargarPorIdLead no se usa acá — tocar una card de
            // ContactoNegociacionesTab abre EditLeadPage con SU PROPIO
            // InfoLeadCubit (sin pasar cubit), justamente para no disparar
            // InfoLeadLoading sobre este cubit y tumbar toda esta pantalla.
            null,
            GetLeadDetallePorNumeroUseCase(context.read<LeadRepository>()),
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
      child: ContactoDetalleView(idNumero: idNumero),
    );
  }
}
