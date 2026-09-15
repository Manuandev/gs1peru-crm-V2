// lib/features/lead/presentation/cubit/recordatorios/recordatorios_lead_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class RecordatoriosLeadCubit extends Cubit<RecordatoriosLeadState> {
  final GetRecordatoriosPorContacto _obtenerRecordatoriosPorContactoUseCase;

  RecordatoriosLeadCubit({
    required GetRecordatoriosPorContacto
    obtenerRecordatoriosPorContactoUseCase,
  }) : _obtenerRecordatoriosPorContactoUseCase =
           obtenerRecordatoriosPorContactoUseCase,
       super(const RecordatoriosLeadInitial());

  Future<void> cargarRecordatoriosPorContacto(int idContacto) async {
    emit(const RecordatoriosLeadLoading());
    try {
      final recordatorios = await _obtenerRecordatoriosPorContactoUseCase.call(
        idContacto,
      );
      // La pantalla pudo cerrarse mientras llegaba la respuesta.
      if (isClosed) return;
      emit(RecordatoriosLeadSuccess(recordatorios: recordatorios));
    } catch (e) {
      if (isClosed) return;
      emit(RecordatoriosLeadError(mensaje: e.toString()));
    }
  }
}
