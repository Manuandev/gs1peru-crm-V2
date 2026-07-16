// lib/features/solicitudes/data/models/solicitud_detalle_model.dart
//
// Parseo de [CRM].[CSV_SOLICITUD_LST_APP], task 'DT' — trae solicitante,
// facturación, participantes y archivos de una solicitud ya guardada, dado
// su NUMSOL. Solo trae IDs de catálogo (sin descripciones); es
// SolicitudCompletarView quien resuelve los labels contra CatalogsBloc antes
// de construir DatosSolicitante/DatosFacturacion/ParticipanteLocal.

import 'package:app_crm/core/index_core.dart';

class SolicitudParticipanteRaw {
  final String id;
  final String tipoDocId;
  final String numDoc;
  final String nacionalidadId;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String celular;
  final String cargo;
  final double importe;
  final String tipoParticipante;

  const SolicitudParticipanteRaw({
    required this.id,
    required this.tipoDocId,
    required this.numDoc,
    required this.nacionalidadId,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.celular,
    required this.cargo,
    required this.importe,
    required this.tipoParticipante,
  });

  factory SolicitudParticipanteRaw.fromCampos(List<String> c) {
    return SolicitudParticipanteRaw(
      id: c[0],
      tipoDocId: c[1],
      numDoc: c[2],
      nacionalidadId: c[3],
      nombres: c[4],
      apellidoPaterno: c[5],
      apellidoMaterno: c[6],
      correo: c[7],
      celular: c[8],
      cargo: c[9],
      importe: double.tryParse(c[10]) ?? 0,
      tipoParticipante: c[11],
    );
  }
}

class SolicitudArchivoRaw {
  final String tipo; // 'voucher' | 'oc'
  final String archivoId;
  final String nombre;
  final String extension;

  const SolicitudArchivoRaw({
    required this.tipo,
    required this.archivoId,
    required this.nombre,
    required this.extension,
  });

  factory SolicitudArchivoRaw.fromCampos(List<String> c) {
    return SolicitudArchivoRaw(
      tipo: c[0],
      archivoId: c[1],
      nombre: c[2],
      extension: c[3],
    );
  }
}

class SolicitudDetalleModel {
  // ── Solicitante ──
  final String tipoPersona; // 'juridica' | 'natural'
  final String tipoDocId;
  final String numDoc;
  final String ruc;
  final String razonSocial;
  final String nacionalidadId;
  final String sexoId;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String cargo;
  final String celular;
  final String correo;
  final bool solicitanteEsParticipante;
  final bool facturarAlSolicitante;
  final String idParticipanteSolicitante;
  final String canalId;
  final String canalNombre;

  // ── Facturación ──
  final String facTipoDocId;
  final String facNumDoc;
  final String facRuc;
  final String facNomEmpre;
  final String facNombres;
  final String facApellidoPaterno;
  final String facApellidoMaterno;
  final String facPaisId;
  final String facCelular;
  final String facCorreo;
  final String facDireccion;
  final String facMonedaId;
  final String facComprobanteId;
  // Nacionalidad de facturación — campo agregado el 2026-07-16 al final del
  // SP (campos[38]), separado de facPaisId (el SP antes reusaba la misma
  // columna ID_NACION_FAC para ID_NACIONALIDAD e ID_PAIS, así que este dato
  // nunca sobrevivía a reabrir la solicitud). Ver CLAUDE.md.
  final String facNacionalidadId;

  // ── Generales ──
  final double dcImporte;
  final double dcIgv;
  final double dcImporteTotal;
  final bool ibValidado;
  final String idEstadoGes;
  final int cantParticipantes;

  final List<SolicitudParticipanteRaw> participantes;
  final List<SolicitudArchivoRaw> archivos;

  const SolicitudDetalleModel({
    required this.tipoPersona,
    required this.tipoDocId,
    required this.numDoc,
    required this.ruc,
    required this.razonSocial,
    required this.nacionalidadId,
    required this.sexoId,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.cargo,
    required this.celular,
    required this.correo,
    required this.solicitanteEsParticipante,
    required this.facturarAlSolicitante,
    required this.idParticipanteSolicitante,
    required this.canalId,
    required this.canalNombre,
    required this.facTipoDocId,
    required this.facNumDoc,
    required this.facRuc,
    required this.facNomEmpre,
    required this.facNombres,
    required this.facApellidoPaterno,
    required this.facApellidoMaterno,
    required this.facPaisId,
    required this.facCelular,
    required this.facCorreo,
    required this.facDireccion,
    required this.facMonedaId,
    required this.facComprobanteId,
    required this.facNacionalidadId,
    required this.dcImporte,
    required this.dcIgv,
    required this.dcImporteTotal,
    required this.ibValidado,
    required this.idEstadoGes,
    required this.cantParticipantes,
    required this.participantes,
    required this.archivos,
  });

  /// true si el paso 3 (Facturación) fue saltado al guardar (todos los
  /// participantes eran invitados) — no hay tipo/número de documento de
  /// facturación guardado. Ver "Regla de negocio — saltar Facturación" en
  /// el CLAUDE.md del feature.
  bool get sinFacturacion => facTipoDocId.isEmpty && facNumDoc.isEmpty;

  factory SolicitudDetalleModel.fromRawString(String raw) {
    final secciones = raw.split(AppConstants.sepListas);
    final campos = secciones[0].split(AppConstants.sepCampos);

    final participantes = secciones.length > 1 && secciones[1].isNotEmpty
        ? secciones[1]
              .split(AppConstants.sepRegistros)
              .map(
                (r) => SolicitudParticipanteRaw.fromCampos(
                  r.split(AppConstants.sepCampos),
                ),
              )
              .toList()
        : <SolicitudParticipanteRaw>[];

    final archivos = secciones.length > 2 && secciones[2].isNotEmpty
        ? secciones[2]
              .split(AppConstants.sepRegistros)
              .map(
                (r) => SolicitudArchivoRaw.fromCampos(
                  r.split(AppConstants.sepCampos),
                ),
              )
              .toList()
        : <SolicitudArchivoRaw>[];

    return SolicitudDetalleModel(
      tipoPersona: campos[1] == 'J' ? 'juridica' : 'natural',
      tipoDocId: campos[2],
      numDoc: campos[3],
      ruc: campos[4],
      razonSocial: campos[5],
      nacionalidadId: campos[6],
      sexoId: campos[7],
      nombres: campos[8],
      apellidoPaterno: campos[9],
      apellidoMaterno: campos[10],
      cargo: campos[11],
      celular: campos[12],
      correo: campos[13],
      solicitanteEsParticipante: campos[14] == '1',
      facturarAlSolicitante: campos[15] == '1',
      idParticipanteSolicitante: campos[16],
      canalId: campos[17],
      canalNombre: campos[18],
      facTipoDocId: campos[19],
      facNumDoc: campos[20],
      facRuc: campos[21],
      facNomEmpre: campos[22],
      facNombres: campos[23],
      facApellidoPaterno: campos[24],
      facApellidoMaterno: campos[25],
      facPaisId: campos[26],
      facCelular: campos[27],
      facCorreo: campos[28],
      facDireccion: campos[29],
      facMonedaId: campos[30],
      facComprobanteId: campos[31],
      dcImporte: double.tryParse(campos[32]) ?? 0,
      dcIgv: double.tryParse(campos[33]) ?? 0,
      dcImporteTotal: double.tryParse(campos[34]) ?? 0,
      ibValidado: campos[35] == '1',
      idEstadoGes: campos[36],
      cantParticipantes: int.tryParse(campos[37]) ?? 0,
      facNacionalidadId: campos.length > 38 ? campos[38] : '',
      participantes: participantes,
      archivos: archivos,
    );
  }
}
