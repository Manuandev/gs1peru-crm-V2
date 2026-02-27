// lib/features/recordatorios/presentation/bloc/recordatorios_bloc.dart


import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:app_crm/features/recordatorios/domain/repositories/i_recordatorios_repository.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'recordatorios_state.dart';

class RecordatoriosBloc extends Bloc<RecordatoriosEvent, RecordatoriosState> {
  final IRecordatoriosRepository _recordatoriosRepository;

  RecordatoriosBloc({
    required IRecordatoriosRepository recordatoriosRepository,
  }) : _recordatoriosRepository = recordatoriosRepository,
       super(const RecordatoriosInitial()) {
    on<RecordatoriosStarted>(_onRecordatoriosStarted);
    on<RecordatoriosRefreshRequested>(_onRecordatoriosRefreshRequested);
  }

  Future<void> _onRecordatoriosStarted(
    RecordatoriosStarted event,
    Emitter<RecordatoriosState> emit,
  ) async {
    emit(const RecordatoriosLoading());
    await _loadData(emit);
  }

  Future<void> _onRecordatoriosRefreshRequested(
    RecordatoriosRefreshRequested event,
    Emitter<RecordatoriosState> emit,
  ) async {
    emit(const RecordatoriosLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<RecordatoriosState> emit) async {
    try {
      final recordatoriosF = _recordatoriosRepository.listarRecordatorios();

      final recordatorios = await recordatoriosF.catchError(
        (_) => <RecordatorioItem>[],
      );

      emit(RecordatoriosLoaded(recordatorios: recordatorios));
    } catch (e, stackTrace) {
      addError(e, stackTrace);

      emit(RecordatoriosError(e.toString()));
    }
  }
}
