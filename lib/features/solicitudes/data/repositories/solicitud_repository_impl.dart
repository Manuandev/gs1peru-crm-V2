// lib/features/solicitudes/data/repositories/solicitud_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_detalle_model.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_model.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud_detalle.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud_pagina.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudRemoteDatasource _remote;

  SolicitudRepositoryImpl(this._remote);

  @override
  Future<List<SolicitudModel>> getSolicitudes() => _remote.getSolicitudes();

  @override
  Future<SolicitudPagina> traerPagina({
    String chip = '',
    String? idAsesor,
    String? cursorFecha,
    String? cursorNumsol,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
    String busqueda = '',
  }) => _remote.traerPagina(
    chip: chip,
    idAsesor: idAsesor,
    cursorFecha: cursorFecha,
    cursorNumsol: cursorNumsol,
    tamanio: tamanio,
    fcDesde: fcDesde,
    fcHasta: fcHasta,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
    busqueda: busqueda,
  );

  @override
  Future<SolicitudDetalleModel> getSolicitudDetalle(String numSol) =>
      _remote.getSolicitudDetalle(numSol);

  @override
  Future<SolicitudDetalle> getDetalleSolicitud(String numSol) =>
      _remote.getDetalleSolicitud(numSol);

  @override
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
    required String pasoOrigen,
    required List<TipoParticipanteItem> tiposParticipante,
    int? cantidadEsperada,
    required TotalesSolicitud totales,
  }) => _remote.guardarSolicitud(
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

  @override
  Future<CrudResult> eliminarSolicitud(String numSol) =>
      _remote.eliminarSolicitud(numSol);

  @override
  Future<List<int>> descargarPlantillaCargaMasiva() =>
      _remote.descargarPlantillaCargaMasiva();
}
