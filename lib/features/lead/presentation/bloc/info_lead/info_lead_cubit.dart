// lib/features/chat/presentation/bloc/info_lead/info_lead_cubit.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class InfoLeadCubit extends Cubit<InfoLeadState> {
  final GetInfoUseCase _getInfo;
  final UpdateLeadEstadoUseCase _updateEstado;
  final UpdateLeadInfoUseCase _updateInfo;

  final _successController = StreamController<String>.broadcast();
  Stream<String> get successes => _successController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errores => _errorController.stream;

  InfoLeadCubit(this._getInfo, this._updateEstado, this._updateInfo)
    : super(const InfoLeadInitial());

  @override
  Future<void> close() {
    _successController.close();
    _errorController.close();
    return super.close();
  }

  Future<void> load(int idLead) async {
    if (isClosed) return;

    emit(const InfoLeadLoading());
    try {
      final info = await _getInfo(idLead);
      if (isClosed) return;
      emit(InfoLeadSuccess(info));
    } on AppException catch (e) {
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  void updateFavorito(bool value) {
    if (state is! InfoLeadSuccess) return;
    final current = (state as InfoLeadSuccess).infoLead;
    emit(InfoLeadSuccess(current.copyWith(isFavorito: value)));
  }

  Future<void> updateEstado({
    required int idLead,
    required String idEstado,
    required String estado,
  }) async {
    if (state is! InfoLeadSuccess) return;

    final snapshot = (state as InfoLeadSuccess).infoLead;

    emit(
      InfoLeadSuccess(snapshot.copyWith(idEstado: idEstado, estado: estado)),
    );

    try {
      final result = await _updateEstado(idLead, idEstado);

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message):
          _successController.add(message);
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(InfoLeadSuccess(snapshot));
          _errorController.add(message);
        case CrudNoInternet():
          emit(InfoLeadSuccess(snapshot));
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(InfoLeadSuccess(snapshot));
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      emit(InfoLeadSuccess(snapshot));
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }

  Future<void> updateLead({
    String? idEstado,
    String? estado,
    String? idSubEstado,
    String? subEstado,
    int? idCampania,
    String? campania,
    int? idEvento,
    String? evento,
    bool clearEvento = false,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
  }) async {
    if (state is! InfoLeadSuccess) return;
    final current = (state as InfoLeadSuccess).infoLead;

    final updated = current.copyWith(
      idEstado: idEstado,
      estado: estado,
      idSubEstado: idSubEstado,
      subEstado: subEstado,
      idCampania: idCampania,
      campania: campania,
      idEvento: idEvento,
      evento: evento,
      clearEvento: clearEvento,
      idCanal: idCanal,
      canal: canal,
      idInteres: idInteres,
      interes: interes,
    );

    emit(InfoLeadSuccess(updated));

    try {
      final result = await _updateInfo(updated);

      if (isClosed) return;

      switch (result) {
        case CrudOk(:final message):
          _successController.add(message);
          break;
        case CrudAlert(:final message):
          _errorController.add(message);
        case CrudError(:final message):
          emit(InfoLeadSuccess(current));
          _errorController.add(message);
        case CrudNoInternet():
          emit(InfoLeadSuccess(current));
          _errorController.add('Sin conexión. Intenta de nuevo.');
        case CrudEmpty():
          emit(InfoLeadSuccess(current));
          _errorController.add('Respuesta inesperada del servidor.');
      }
    } catch (e) {
      if (isClosed) return;
      emit(InfoLeadSuccess(current));
      _errorController.add('No se pudo cambiar el estado. Intenta de nuevo.');
    }
  }
}
