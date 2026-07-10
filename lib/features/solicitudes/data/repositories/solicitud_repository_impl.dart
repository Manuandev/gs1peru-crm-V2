// lib/features/solicitudes/data/repositories/solicitud_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_model.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudRemoteDatasource _remote;

  SolicitudRepositoryImpl(this._remote);

  @override
  Future<List<SolicitudModel>> getSolicitudes() => _remote.getSolicitudes();

  @override
  Future<CrudResult> guardarSolicitud({
    required String numSol,
    required String tipoPersona,
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
  }) => _remote.guardarSolicitud(
    numSol: numSol,
    tipoPersona: tipoPersona,
    solicitante: solicitante,
    facturacion: facturacion,
    participantes: participantes,
    igvPorcentaje: igvPorcentaje,
    esBorrador: esBorrador,
  );

  @override
  Future<bool> guardarArchivo({
    required String numSol,
    required String tipo,
    required String fileName,
    required String fileExt,
    required List<int> fileBytes,
  }) => _remote.guardarArchivo(
    numSol: numSol,
    tipo: tipo,
    fileName: fileName,
    fileExt: fileExt,
    fileBytes: fileBytes,
  );
}
