// lib/features/solicitudes/domain/repositories/solicitud_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_detalle_model.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud_detalle.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

abstract class SolicitudRepository {
  Future<List<Solicitud>> getSolicitudes();

  Future<SolicitudDetalleModel> getSolicitudDetalle(String numSol);

  // Task 'DV' — detalle de solo lectura, ver SolicitudRemoteDatasource.
  Future<SolicitudDetalle> getDetalleSolicitud(String numSol);

  Future<CrudResult> guardarSolicitud({
    required String numSol,
    required String idLead,
    required String tipoPersona,
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
    required String idTipoDocRuc,
  });

  Future<bool> guardarArchivo({
    required String numSol,
    required String tipo,
    required String fileName,
    required String fileExt,
    required List<int> fileBytes,
  });

  Future<CrudResult> eliminarSolicitud(String numSol);
}
