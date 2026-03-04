import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Chats',
      drawerSide: DrawerSide.left,
      onSearch: (query) {
        context.read<ChatListBloc>().add(ChatListSearched(query));
      },
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
      body: BlocConsumer<ChatListBloc, ChatListState>(
        // 👇 snack solo cuando ya había datos y falla el refresh
        listenWhen: (previous, current) =>
            previous is ChatListSuccess && current is ChatListFailure,
        listener: (context, state) {
          if (state is ChatListFailure) {
            context.showErrorSnack(state.message);
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
            if (state.chats.isEmpty) return const AppEmptyView();

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
    );
  }
}
