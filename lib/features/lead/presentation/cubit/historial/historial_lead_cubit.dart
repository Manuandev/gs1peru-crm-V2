// lib/features/lead/presentation/cubit/historial/historial_lead_cubit.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/presentation/cubit/historial/historial_lead_state.dart';

class HistorialLeadCubit extends Cubit<HistorialLeadState> {
  HistorialLeadCubit() : super(const HistorialLeadInitial());

  Future<void> cargarHistorial(int leadId) async {
    emit(const HistorialLeadLoading());
    try {
      // TODO: final result = await _repository.getHistorial(leadId);
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const HistorialLeadSuccess(eventos: _datosFake));
    } catch (e) {
      emit(HistorialLeadError(mensaje: e.toString()));
    }
  }
}

const _datosFake = [
  HistorialItemFake(
    descripcion: 'Lead creado desde Click-to-WhatsApp Ads',
    fechaHora: '19/05/2026 · 10:05',
    tipoActor: TipoActor.sistema,
    actor: 'Sistema',
  ),
  HistorialItemFake(
    descripcion: 'Bot IA inició la conversación y solicitó datos básicos',
    fechaHora: '19/05/2026 · 10:06',
    tipoActor: TipoActor.botIA,
    actor: 'Bot IA',
  ),
  HistorialItemFake(
    descripcion: 'Brochure enviado en PDF',
    fechaHora: '19/05/2026 · 10:12',
    tipoActor: TipoActor.botIA,
    actor: 'Bot IA',
  ),
  HistorialItemFake(
    descripcion: 'Cliente solicitó precio',
    fechaHora: '19/05/2026 · 10:14',
    tipoActor: TipoActor.cliente,
    actor: 'Cliente',
  ),
  HistorialItemFake(
    descripcion: 'Conversación derivada al asesor Julio Flores',
    fechaHora: '19/05/2026 · 10:16',
    tipoActor: TipoActor.sistema,
    actor: 'Sistema',
  ),
  HistorialItemFake(
    descripcion: 'Se creó negociación Excel Avanzado - Junio 2026',
    fechaHora: '19/05/2026 · 10:17',
    tipoActor: TipoActor.asesor,
    actor: 'Julio Flores',
  ),
  HistorialItemFake(
    descripcion: 'Estado cambiado a En desarrollo',
    fechaHora: '19/05/2026 · 10:18',
    tipoActor: TipoActor.asesor,
    actor: 'Julio Flores',
  ),
];
