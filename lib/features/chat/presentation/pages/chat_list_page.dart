// lib\features\chat\presentation\pages\chat_list_page.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatListBloc(
        GetChatsUseCase(ChatRepositoryImpl(ChatRemoteDatasource())),
      )..add(const ChatListStarted()),
      child: BlocListener<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state is ChatListSuccess) {
            context.updateBadge(chats: state.chats.length);
          }
        },
        child: const ChatListView(),
      ),
    );
  }
}
