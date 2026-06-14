// lib/features/chat/presentation/bloc/template/select_template_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class SelectTemplateBloc
    extends Bloc<SelectTemplateEvent, SelectTemplateState> {
  final GetTemplatesUseCase _getData;

  SelectTemplateBloc({required GetTemplatesUseCase getData})
    : _getData = getData,
      super(const SelectTemplateInitial()) {
    on<SelectTemplateStarted>(_onStarted);
    on<SelectTemplateRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    SelectTemplateStarted event,
    Emitter<SelectTemplateState> emit,
  ) async {
    emit(const SelectTemplateLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    SelectTemplateRefresh event,
    Emitter<SelectTemplateState> emit,
  ) async {
    emit(const SelectTemplateLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<SelectTemplateState> emit) async {
    try {
      final templates = await _getData.call();

      emit(
        SelectTemplateLoaded(
          templates: templates,
        ),
      );
    } on AppException catch (e) {
      emit(SelectTemplateError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(SelectTemplateError(e.toString()));
    }
  }
}
