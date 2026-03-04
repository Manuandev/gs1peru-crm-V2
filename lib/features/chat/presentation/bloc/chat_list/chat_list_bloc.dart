
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChats;
  List<Chat> _allChats = [];

  ChatListBloc(this._getChats) : super(const ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListRefreshed>(_onRefreshed);
    on<ChatListSearched>(_onSearched);
  }

  Future<void> _onStarted(
    ChatListStarted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ChatListRefreshed event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ChatListState> emit) async {
    try {
      final chats = await _getChats();
      _allChats = chats;

      emit(ChatListSuccess(chats: chats));
    } on AppException catch (e) {
      emit(ChatListFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ChatListFailure('Ocurrió un error inesperado.'));
    }
  }

  void _onSearched(ChatListSearched event, Emitter<ChatListState> emit) {
    if (state is! ChatListSuccess) return;

    if (event.query.isEmpty) {
      emit(ChatListSuccess(chats: _allChats));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = _allChats.where((chat) {
      return chat.nombreApe.toLowerCase().contains(query) ||
          chat.telefono.toLowerCase().contains(query);
    }).toList();

    emit(ChatListSuccess(chats: filtered));
  }
}
