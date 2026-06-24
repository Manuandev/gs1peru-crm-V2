// lib/features/chat/presentation/widgets/chat_list/chat_list_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mis conversaciones',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          Text(
            'Ordenadas por última interacción',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white(0.75),
            ),
          ),
        ],
      ),
      onPop: () => context.goToHome(),
      drawerSide: DrawerSide.left,
      onSearch: (query) {
        context.read<ChatListBloc>().add(ChatListSearched(query));
      },
      // Botón de filtro avanzado (abre endDrawer derecho)
      appBarTrailingButtons: [
        BlocBuilder<ChatListBloc, ChatListState>(
          buildWhen: (prev, curr) {
            final prevHas = prev is ChatListSuccess && prev.tieneFiltroAvanzado;
            final currHas = curr is ChatListSuccess && curr.tieneFiltroAvanzado;
            return prevHas != currHas;
          },
          builder: (context, state) {
            final tieneAvanzado = state is ChatListSuccess && state.tieneFiltroAvanzado;
            return Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Filtrar',
                icon: Icon(
                  AppIcons.filter,
                  color: tieneAvanzado ? AppColors.secondary : AppColors.textOnDark,
                ),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            );
          },
        ),
      ],
      showBottomNav: true,
      // Panel lateral derecho para filtros avanzados
      endDrawerWidget: const FiltroChatDrawer(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          final bloc = context.read<ChatListBloc>();
          bloc.add(ChatListRefreshed());
          await bloc.stream.firstWhere(
            (s) => s is ChatListSuccess || s is ChatListError,
          );
        },
        child: Column(
          children: [
            // ── Sección fija: chips + contadores ──────────────────
            BlocBuilder<ChatListBloc, ChatListState>(
              buildWhen: (prev, curr) => curr is ChatListSuccess,
              builder: (context, state) {
                if (state is! ChatListSuccess) return const SizedBox.shrink();
                return Column(
                  children: [
                    ChatListFilterChips(
                      filtroActual: state.filtro,
                      conteos: state.conteos,
                      onFiltroTap: (filtro) {
                        context.read<ChatListBloc>().add(ChatListFiltered(filtro));
                      },
                    ),
                    ContadoresChatRow(contadores: state.contadores),
                  ],
                );
              },
            ),

            // ── Lista scrollable ───────────────────────────────────
            Expanded(
              child: BlocConsumer<ChatListBloc, ChatListState>(
                listenWhen: (previous, current) =>
                    previous is ChatListSuccess && current is ChatListError,
                listener: (context, state) {
                  if (state is ChatListError) {
                    AppSnackBar.error(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ChatListInitial || state is ChatListLoading) {
                    return const AppLoadingView();
                  }

                  if (state is ChatListError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<ChatListBloc>().add(ChatListRefreshed()),
                    );
                  }

                  if (state is ChatListSuccess) {
                    if (state.conversaciones.isEmpty) {
                      return AppEmptyView(message: _emptyMessage(state.filtro));
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: OrientationBuilder(
                        builder: (context, _) => ChatListPortrait(state: state),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emptyMessage(ChatListFiltro filtro) {
    return switch (filtro) {
      ChatListFiltro.todos => 'No hay chats abiertos y/o disponibles.',
      ChatListFiltro.sinResponder => '¡Todo al día! No hay chats sin responder.',
      ChatListFiltro.enDesarrollo => 'No hay chats en desarrollo.',
      ChatListFiltro.conPropuesta => 'No hay conversaciones con propuesta enviada.',
      ChatListFiltro.enCobranza => 'No hay conversaciones en proceso de cobranza.',
    };
  }
}
