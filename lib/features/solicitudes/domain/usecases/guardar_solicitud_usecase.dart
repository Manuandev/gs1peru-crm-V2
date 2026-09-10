// lib/features/solicitudes/domain/usecases/guardar_solicitud_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

class GuardarSolicitudUseCase {
  final SolicitudRepository _repository;
  const GuardarSolicitudUseCase(this._repository);

  Future<CrudResult> call({
    required String numSol,
    String idLead = '',
    required String tipoPersona,
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
    required String idTipoDocRuc,
    required String pasoOrigen,
    required List<TipoParticipanteItem> tiposParticipante,
    int? cantidadEsperada,
    required TotalesSolicitud totales,
  }) => _repository.guardarSolicitud(
    numSol: numSol,
    idLead: idLead,
    tipoPersona: tipoPersona,
    solicitante: solicitante,
    facturacion: facturacion,
    participantes: participantes,
    igvPorcentaje: igvPorcentaje,
    esBorrador: esBorrador,
    idTipoDocRuc: idTipoDocRuc,
    pasoOrigen: pasoOrigen,
    tiposParticipante: tiposParticipante,
    cantidadEsperada: cantidadEsperada,
    totales: totales,
  );
}
