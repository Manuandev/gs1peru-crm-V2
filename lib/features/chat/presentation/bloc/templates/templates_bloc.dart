// lib\features\chat\presentation\bloc\templates\templates_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  TemplatesBloc() : super(const TemplatesInitial()) {
    on<TemplatesStarted>(_onStarted);
    on<TemplatesRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    TemplatesStarted event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    TemplatesRefresh event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<TemplatesState> emit) async {
    try {
      emit(TemplatesLoaded());
    } on AppException catch (e) {
      emit(TemplatesError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(TemplatesError(e.toString()));
    }
  }
}
