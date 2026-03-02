

import 'package:app_crm/features/chat/data/datasources/remote/chats_remote_datasource.dart';
import 'package:app_crm/features/chat/data/repositories/chats_repository.dart';
import 'package:app_crm/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:app_crm/features/chat/presentation/widgets/chats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import '../bloc/chats_bloc.dart';
import '../bloc/chats_event.dart';
import '../bloc/chats_state.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatsBloc(
              getChatsUsecase: GetChatsUsecase(
    repository: ChatsRepository(
      remote: ChatsRemoteDatasource(),
    ),
  ),
            )
            ..add(const ChatsStarted()),
      child: BlocListener<ChatsBloc, ChatsState>(
        // Solo escucha errores para mostrar snackbar
        listenWhen: (_, current) => current is ChatsError,
        listener: (context, state) {
          context.showErrorSnack((state as ChatsError).message);
        },
        child: const ChatsView (),
        // child: const RecordatoriosView(),
      ),
    );
  }
}
