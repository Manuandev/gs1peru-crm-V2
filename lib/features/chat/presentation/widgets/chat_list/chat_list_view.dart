import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      title: 'Mis conversaciones',
      onPop: () => context.goToHome(),
      drawerSide: DrawerSide.left,
      appBarPopupItems: const [
        AppBarPopupItem(
          value: 'refresh',
          icon: AppIcons.refresh,
          label: 'Actualizar',
        ),
      ],
      onPopupSelected: (value) {
        switch (value) {
          case 'refresh':
            context.read<ChatListBloc>().add(ChatListRefreshed());
        }
      },
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────
          ChatListSearchBar(
            controller: _searchController,
            onChanged: (query) {
              context.read<ChatListBloc>().add(ChatListSearched(query));
            },
            onClear: () {
              _searchController.clear();
              context.read<ChatListBloc>().add(ChatListSearched(''));
            },
          ),

          // ── Chips de filtro ────────────────────────────
          BlocBuilder<ChatListBloc, ChatListState>(
            buildWhen: (prev, curr) => curr is ChatListSuccess,
            builder: (context, state) {
              if (state is! ChatListSuccess) return const SizedBox.shrink();
              return ChatListFilterChips(
                filtroActual: state.filtro,
                conteos: state.conteos,
                onFiltroTap: (filtro) {
                  context.read<ChatListBloc>().add(ChatListFiltered(filtro));
                },
              );
            },
          ),

          // ── Lista ──────────────────────────────────────
          Expanded(
            child: BlocConsumer<ChatListBloc, ChatListState>(
              listenWhen: (previous, current) =>
                  previous is ChatListSuccess && current is ChatListFailure,
              listener: (context, state) {
                if (state is ChatListFailure) {
                  AppSnackBar.error(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is ChatListInitial || state is ChatListLoading) {
                  return const AppLoadingView();
                }

                if (state is ChatListFailure) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<ChatListBloc>().add(ChatListRefreshed()),
                  );
                }

                if (state is ChatListSuccess) {
                  if (state.chats.isEmpty) {
                    return AppEmptyView(message: _emptyMessage(state.filtro));
                  }

                  return OrientationBuilder(
                    builder: (context, orientation) {
                      if (orientation == Orientation.landscape) {
                        return ChatListLandscape(state: state);
                      }
                      return ChatListPortrait(state: state);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _emptyMessage(ChatListFiltro filtro) {
    switch (filtro) {
      case ChatListFiltro.sinResponder:
        return '¡Todo al día! No hay chats sin responder.';
      case ChatListFiltro.enDesarrollo:
        return 'No hay chats en desarrollo.';
      case ChatListFiltro.todos:
        return 'No hay chats abiertos y/o disponibles.';
    }
  }
}
