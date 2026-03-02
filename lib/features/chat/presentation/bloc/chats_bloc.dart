import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:app_crm/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetChatsUsecase _getChatsUsecase;
  List<ChatItem> _allChats = [];

  ChatsBloc({required GetChatsUsecase getChatsUsecase})
    : _getChatsUsecase = getChatsUsecase,
      super(const ChatsInitial()) {
    on<ChatsStarted>(_onChatsStarted);
    on<ChatsRefreshRequested>(_onChatsRefreshRequested);
    on<ChatsSearchRequested>(_onChatsSearchRequested);
  }

  Future<void> _onChatsStarted(
    ChatsStarted event,
    Emitter<ChatsState> emit,
  ) async {
    emit(const ChatsLoading());
    await _loadData(emit);
  }

  Future<void> _onChatsRefreshRequested(
    ChatsRefreshRequested event,
    Emitter<ChatsState> emit,
  ) async {
    emit(const ChatsLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ChatsState> emit) async {
    try {
      final chats = await _getChatsUsecase.execute();

      _allChats = chats;

      emit(ChatsLoaded(chats: chats));
    } catch (e, stackTrace) {
      addError(e, stackTrace);

      emit(ChatsError(e.toString()));
    }
  }

  void _onChatsSearchRequested(
    ChatsSearchRequested event,
    Emitter<ChatsState> emit,
  ) {
    if (state is ChatsLoaded) {
      if (event.query.isEmpty) {
        emit(ChatsLoaded(chats: _allChats));
        return;
      }

      final filtered = _allChats.where((chat) {
        return (chat.nombreApe.toLowerCase().contains(
              event.query.toLowerCase(),
            ) ||
            chat.telefono.toLowerCase().contains(event.query.toLowerCase()));
      }).toList();

      emit(ChatsLoaded(chats: filtered));
    }
  }
}
