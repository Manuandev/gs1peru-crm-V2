// lib\features\chat\presentation\bloc\templates\templates_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadBloc extends Bloc<EditLeadEvent, EditLeadState> {
  EditLeadBloc() : super(const EditLeadInitial()) {
    on<EditLeadStarted>(_onStarted);
    on<EditLeadRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    EditLeadStarted event,
    Emitter<EditLeadState> emit,
  ) async {
    emit(const EditLeadLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    EditLeadRefresh event,
    Emitter<EditLeadState> emit,
  ) async {
    emit(const EditLeadLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<EditLeadState> emit) async {
    try {
      emit(const EditLeadLoaded());
    } on AppException catch (e) {
      emit(EditLeadError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(EditLeadError(e.toString()));
    }
  }
}
