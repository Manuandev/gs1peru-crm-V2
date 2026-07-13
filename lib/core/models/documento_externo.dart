// lib/core/models/documento_externo.dart

import 'package:app_crm/core/index_core.dart';

// Respuesta unificada de Clientes/BuscarDocumento (ver cobranza/CLAUDE.md o
// solicitudes/CLAUDE.md para el contrato completo). El backend intenta primero
// el cliente ya registrado (INTERNO) y si no encuentra datos suficientes cae a
// RENIEC (DNI) o al espejo local de SUNAT (RUC) — origen indica cuál resolvió.
class DocumentoExterno {
  final String origen; // 'INTERNO' | 'RENIEC' | 'SUNAT'
  final String nomEmpresa;
  final String ubigeo;
  final String direccion;
  final String activoSunat;
  final String habidoSunat;
  final String registradoSunat;
  final String nombres;
  final String apePaterno;
  final String apeMaterno;
  final String idPais;
  final String idNacionalidad;
  final String correo;

  const DocumentoExterno({
    this.origen = '',
    this.nomEmpresa = '',
    this.ubigeo = '',
    this.direccion = '',
    this.activoSunat = '',
    this.habidoSunat = '',
    this.registradoSunat = '',
    this.nombres = '',
    this.apePaterno = '',
    this.apeMaterno = '',
    this.idPais = '',
    this.idNacionalidad = '',
    this.correo = '',
  });

  bool get sinDatos => origen.isEmpty;
}

class DocumentoExternoModel extends DocumentoExterno {
  const DocumentoExternoModel({
    super.origen,
    super.nomEmpresa,
    super.ubigeo,
    super.direccion,
    super.activoSunat,
    super.habidoSunat,
    super.registradoSunat,
    super.nombres,
    super.apePaterno,
    super.apeMaterno,
    super.idPais,
    super.idNacionalidad,
    super.correo,
  });

  factory DocumentoExternoModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return DocumentoExternoModel(
      origen: ParseUtils.str(c, 0),
      nomEmpresa: ParseUtils.str(c, 1),
      ubigeo: ParseUtils.str(c, 2),
      direccion: ParseUtils.str(c, 3),
      activoSunat: ParseUtils.str(c, 4),
      habidoSunat: ParseUtils.str(c, 5),
      registradoSunat: ParseUtils.str(c, 6),
      nombres: ParseUtils.str(c, 7),
      apePaterno: ParseUtils.str(c, 8),
      apeMaterno: ParseUtils.str(c, 9),
      idPais: ParseUtils.str(c, 10),
      idNacionalidad: ParseUtils.str(c, 11),
      correo: ParseUtils.str(c, 12),
    );
  }
}
