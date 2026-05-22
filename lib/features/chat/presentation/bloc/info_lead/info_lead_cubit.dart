// lib\features\chat\presentation\bloc\info_lead\info_lead_cubit.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoLeadCubit extends Cubit<InfoLeadState> {
  final GetInfoUseCase _getInfo;

  InfoLeadCubit(this._getInfo) : super(const InfoLeadInitial());

  Future<void> load(String idLead) async {
    emit(const InfoLeadLoading());
    try {
      final info = await _getInfo(idLead);
      emit(InfoLeadSuccess(info));
    } on AppException catch (e) {
      emit(InfoLeadFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const InfoLeadFailure('Ocurrió un error inesperado.'));
    }
  }

  // 👇 Actualiza solo un campo sin recargar todo
  void updateFavorito(bool value) {
    if (state is! InfoLeadSuccess) return;
    final current = (state as InfoLeadSuccess).infoLead;
    emit(InfoLeadSuccess(current.copyWith(isFavorito: value)));
  }

  void updateBloqueado(bool value) {
    if (state is! InfoLeadSuccess) return;
    final current = (state as InfoLeadSuccess).infoLead;
    emit(InfoLeadSuccess(current.copyWith(isBloqueado: value)));
  }

  void updateEstado({required String idEstado, required String estado}) {
    if (state is! InfoLeadSuccess) return;
    final current = (state as InfoLeadSuccess).infoLead;
    emit(InfoLeadSuccess(current.copyWith(idEstado: idEstado, estado: estado)));
  }
}
