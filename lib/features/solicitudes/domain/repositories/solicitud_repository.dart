// lib/features/solicitudes/domain/repositories/solicitud_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

abstract class SolicitudRepository {
  Future<List<Solicitud>> getSolicitudes();

  Future<CrudResult> guardarSolicitud({
    required String numSol,
    required String tipoPersona,
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
  });

  Future<bool> guardarArchivo({
    required String numSol,
    required String tipo,
    required String fileName,
    required String fileExt,
    required List<int> fileBytes,
  });
}
