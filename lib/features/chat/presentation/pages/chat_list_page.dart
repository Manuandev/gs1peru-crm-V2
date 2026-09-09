// lib/features/chat/presentation/pages/chat_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    // ChatListBloc es global (vive en app_widget.dart, no muere con esta page)
    // porque necesita seguir escuchando WebSocket para el badge del drawer aunque
    // el usuario esté en otra pantalla — por eso hace falta refrescar a mano cada
    // vez que se reingresa, a diferencia de Seguimiento/Solicitudes/Cobranza (cuyo
    // bloc se crea de cero en cada entrada a la page).
    // ChatListReset (no ChatListRefreshed): al reingresar desde el menú la
    // pantalla arranca "desde cero" — sin chip/búsqueda/panel avanzado activos
    // que hayan quedado de una visita anterior (el bloc global los conserva).
    context.read<ChatListBloc>().add(const ChatListReset());
    // Mantiene frescos los combos del filtro avanzado (campañas + oportunidades).
    context.read<CatalogsBloc>().add(const CatalogsFiltrosRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatListBloc, ChatListState>(
      listener: (context, state) {
        if (state is ChatListSuccess) {
          context.updateBadge(conversaciones: state.contadores.sinResponder);
        }
      },
      child: const ChatListView(),
    );
  }
}
