// lib/core/models/catalog_item_model.dart

import 'package:app_crm/core/index_core.dart';

class ListasGenericasModel extends ListasGenericas {
  const ListasGenericasModel({
    required super.campanias,
    required super.oportunidades,
    required super.canales,
    required super.intereses,
    super.estados,
    super.asesores,
    super.estadosGestion,
    super.monedas,
    super.igvPorcentaje,
    super.paises,
    super.tiposDocumento,
    super.comprobantes,
    super.nacionalidades,
    super.valoresDefecto,
    super.sexos,
    super.tiposParticipante,
    super.ubigeo,
    super.canalesExpo,
  });

  static ListasGenericasModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final campaniasRaw = partes.isNotEmpty ? partes[0] : '';
    final oportunidadesRaw = partes.length > 1 ? partes[1] : '';
    final canalesRaw = partes.length > 2 ? partes[2] : '';
    final interesesRaw = partes.length > 3 ? partes[3] : '';
    final estadosRaw = partes.length > 4 ? partes[4] : '';
    final asesoresRaw = partes.length > 5 ? partes[5] : '';
    final estadosGestionRaw = partes.length > 6 ? partes[6] : '';
    final monedasRaw = partes.length > 7 ? partes[7] : '';
    final igvRaw = partes.length > 8 ? partes[8] : '';
    final paisesRaw = partes.length > 9 ? partes[9] : '';
    final tiposDocumentoRaw = partes.length > 10 ? partes[10] : '';
    final comprobantesRaw = partes.length > 11 ? partes[11] : '';
    final nacionalidadesRaw = partes.length > 12 ? partes[12] : '';
    final valoresDefectoRaw = partes.length > 13 ? partes[13] : '';
    final sexosRaw = partes.length > 14 ? partes[14] : '';
    final tiposParticipanteRaw = partes.length > 15 ? partes[15] : '';
    final ubigeoRaw = partes.length > 16 ? partes[16] : '';
    final canalesExpoRaw = partes.length > 17 ? partes[17] : '';

    final campanias = campaniasRaw.trim().isEmpty
        ? <CampaniaItemModel>[]
        : CampaniaItemModel.parseList(campaniasRaw);

    final oportunidades = oportunidadesRaw.trim().isEmpty
        ? <OportunidadItemModel>[]
        : OportunidadItemModel.parseList(oportunidadesRaw);

    final canales = canalesRaw.trim().isEmpty
        ? <CanalItemModel>[]
        : CanalItemModel.parseList(canalesRaw);

    final intereses = interesesRaw.trim().isEmpty
        ? <InteresItemModel>[]
        : InteresItemModel.parseList(interesesRaw);

    final estados = estadosRaw.trim().isEmpty
        ? <EstadoItemModel>[]
        : EstadoItemModel.parseList(estadosRaw);

    final asesores = asesoresRaw.trim().isEmpty
        ? <AsesorItemModel>[]
        : AsesorItemModel.parseList(asesoresRaw);

    final estadosGestion = estadosGestionRaw.trim().isEmpty
        ? <EstadoGestionItemModel>[]
        : EstadoGestionItemModel.parseList(estadosGestionRaw);

    final monedas = monedasRaw.trim().isEmpty
        ? <MonedaItemModel>[]
        : MonedaItemModel.parseList(monedasRaw);

    final igvPorcentaje = double.tryParse(igvRaw.trim()) ?? 0;

    final paises = paisesRaw.trim().isEmpty
        ? <PaisItemModel>[]
        : PaisItemModel.parseList(paisesRaw);

    final tiposDocumento = tiposDocumentoRaw.trim().isEmpty
        ? <TipoDocumentoItemModel>[]
        : TipoDocumentoItemModel.parseList(tiposDocumentoRaw);

    final comprobantes = comprobantesRaw.trim().isEmpty
        ? <ComprobanteItemModel>[]
        : ComprobanteItemModel.parseList(comprobantesRaw);

    final nacionalidades = nacionalidadesRaw.trim().isEmpty
        ? <NacionalidadItemModel>[]
        : NacionalidadItemModel.parseList(nacionalidadesRaw);

    final valoresDefecto = valoresDefectoRaw.trim().isEmpty
        ? const ValoresCRMItem()
        : ValoresCRMItemModel.fromRawString(valoresDefectoRaw);

    final sexos = sexosRaw.trim().isEmpty
        ? <SexoItemModel>[]
        : SexoItemModel.parseList(sexosRaw);

    final tiposParticipante = tiposParticipanteRaw.trim().isEmpty
        ? <TipoParticipanteItemModel>[]
        : TipoParticipanteItemModel.parseList(tiposParticipanteRaw);

    final ubigeo = ubigeoRaw.trim().isEmpty
        ? <UbigeoItemModel>[]
        : UbigeoItemModel.parseList(ubigeoRaw);

    final canalesExpo = canalesExpoRaw.trim().isEmpty
        ? <CanalExpoItemModel>[]
        : CanalExpoItemModel.parseList(canalesExpoRaw);

    return ListasGenericasModel(
      campanias: campanias,
      oportunidades: oportunidades,
      canales: canales,
      intereses: intereses,
      estados: estados,
      asesores: asesores,
      estadosGestion: estadosGestion,
      monedas: monedas,
      igvPorcentaje: igvPorcentaje,
      paises: paises,
      tiposDocumento: tiposDocumento,
      comprobantes: comprobantes,
      nacionalidades: nacionalidades,
      valoresDefecto: valoresDefecto,
      sexos: sexos,
      tiposParticipante: tiposParticipante,
      ubigeo: ubigeo,
      canalesExpo: canalesExpo,
    );
  }
}

class CampaniaItemModel extends CampaniaItem {
  const CampaniaItemModel({required super.id, required super.nombre});

  factory CampaniaItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return CampaniaItemModel(
      id: ParseUtils.toInt(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<CampaniaItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CampaniaItemModel.fromRawString(r))
        .toList();
  }
}

class OportunidadItemModel extends OportunidadItem {
  const OportunidadItemModel({
    required super.id,
    required super.idCampania,
    required super.nombre,
    required super.idMoneda,
    required super.importeGeneral,
    required super.importeAsociado,
  });

  factory OportunidadItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return OportunidadItemModel(
      id: ParseUtils.toInt(c, 0),
      idCampania: ParseUtils.toInt(c, 1),
      nombre: ParseUtils.str(c, 2),
      idMoneda: ParseUtils.str(c, 3),
      importeGeneral: ParseUtils.toDouble(c, 4),
      importeAsociado: ParseUtils.toDouble(c, 5),
    );
  }

  static List<OportunidadItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => OportunidadItemModel.fromRawString(r))
        .toList();
  }
}

class CanalItemModel extends CanalItem {
  const CanalItemModel({
    required super.id,
    required super.nombre,
    super.iconoApp,
  });

  factory CanalItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return CanalItemModel(
      id: ParseUtils.toInt(c, 0),
      nombre: ParseUtils.str(c, 1),
      iconoApp: ParseUtils.strNullable(c, 2),
    );
  }

  static List<CanalItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CanalItemModel.fromRawString(r))
        .toList();
  }
}

class InteresItemModel extends InteresItem {
  const InteresItemModel({required super.id, required super.nombre});

  factory InteresItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return InteresItemModel(
      id: ParseUtils.toInt(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<InteresItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => InteresItemModel.fromRawString(r))
        .toList();
  }
}

class EstadoItemModel extends EstadoItem {
  const EstadoItemModel({
    required super.id,
    required super.nombre,
    super.idPadre,
  });

  factory EstadoItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    final padre = ParseUtils.str(c, 1);
    return EstadoItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 2),
      idPadre: padre.isEmpty ? null : padre,
    );
  }

  static List<EstadoItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => EstadoItemModel.fromRawString(r))
        .toList();
  }
}

class AsesorItemModel extends AsesorItem {
  const AsesorItemModel({
    required super.codUser,
    required super.nombre,
    required super.disponible,
  });

  factory AsesorItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return AsesorItemModel(
      codUser: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
      disponible: ParseUtils.toBool(c, 2),
    );
  }

  static List<AsesorItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => AsesorItemModel.fromRawString(r))
        .toList();
  }
}

class EstadoGestionItemModel extends EstadoGestionItem {
  const EstadoGestionItemModel({required super.id, required super.nombre});

  factory EstadoGestionItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return EstadoGestionItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<EstadoGestionItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => EstadoGestionItemModel.fromRawString(r))
        .toList();
  }
}

// SP lstListas parte [7]: codargu ¦ deslarga ¦ descorta ¦ valor4 — SYSTABEXTER02
// CODTABLA='MON'. id usa codargu (string) — el SP de detalle de lead mandará
// su propio idMoneda con este mismo valor para autoseleccionar el combo.
// codigo usa valor4 (ISO, ej. 'PEN'/'USD') para NumberFormatUtils/AppCurrencies.
class MonedaItemModel extends MonedaItem {
  const MonedaItemModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.simbolo,
  });

  factory MonedaItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return MonedaItemModel(
      id: ParseUtils.str(c, 0),
      codigo: ParseUtils.str(c, 3),
      nombre: ParseUtils.str(c, 1),
      simbolo: ParseUtils.str(c, 2),
    );
  }

  static List<MonedaItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => MonedaItemModel.fromRawString(r))
        .toList();
  }
}

class PaisItemModel extends PaisItem {
  const PaisItemModel({
    required super.id,
    required super.nombre,
    required super.codigoTelefono,
  });

  factory PaisItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return PaisItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
      codigoTelefono: ParseUtils.str(c, 2),
    );
  }

  static List<PaisItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => PaisItemModel.fromRawString(r))
        .toList();
  }
}

class TipoDocumentoItemModel extends TipoDocumentoItem {
  const TipoDocumentoItemModel({required super.id, required super.nombre});

  factory TipoDocumentoItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return TipoDocumentoItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<TipoDocumentoItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => TipoDocumentoItemModel.fromRawString(r))
        .toList();
  }
}

class ComprobanteItemModel extends ComprobanteItem {
  const ComprobanteItemModel({required super.id, required super.nombre});

  factory ComprobanteItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return ComprobanteItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<ComprobanteItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ComprobanteItemModel.fromRawString(r))
        .toList();
  }
}

class NacionalidadItemModel extends NacionalidadItem {
  const NacionalidadItemModel({
    required super.id,
    required super.nombre,
    required super.valor4,
  });

  factory NacionalidadItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return NacionalidadItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
      valor4: ParseUtils.str(c, 2),
    );
  }

  static List<NacionalidadItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NacionalidadItemModel.fromRawString(r))
        .toList();
  }
}

// SP lstListas parte [13]: fila única, orden fijo — ver comentario en
// ValoresCRMItem (catalog_item.dart). Sin fromRawString.parseList: no es lista.
class ValoresCRMItemModel extends ValoresCRMItem {
  const ValoresCRMItemModel({
    required super.idCanalWsp,
    required super.idPais,
    required super.idNacionalidad,
    required super.idEstadoNuevo,
    required super.idEstadoGanado,
    required super.idTipoBoleta,
    required super.idTipoFactura,
    required super.idTipoDocRuc,
    required super.idTipoDocSnd,
    required super.idTipoDocDni,
    required super.idTipoDocCde,
    required super.idTipoDocPas,
    required super.idEstadoEnDesarrollo,
    required super.idEstadoConPropuesta,
  });

  factory ValoresCRMItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return ValoresCRMItemModel(
      idCanalWsp: ParseUtils.toInt(c, 0),
      idPais: ParseUtils.str(c, 1),
      idNacionalidad: ParseUtils.str(c, 2),
      idEstadoNuevo: ParseUtils.str(c, 3),
      idEstadoGanado: ParseUtils.str(c, 4),
      idTipoBoleta: ParseUtils.str(c, 5),
      idTipoFactura: ParseUtils.str(c, 6),
      idTipoDocRuc: ParseUtils.str(c, 7),
      idTipoDocSnd: ParseUtils.str(c, 8),
      idTipoDocDni: ParseUtils.str(c, 9),
      idTipoDocCde: ParseUtils.str(c, 10),
      idTipoDocPas: ParseUtils.str(c, 11),
      idEstadoEnDesarrollo: ParseUtils.str(c, 12),
      idEstadoConPropuesta: ParseUtils.str(c, 13),
    );
  }
}

class SexoItemModel extends SexoItem {
  const SexoItemModel({required super.id, required super.nombre});

  factory SexoItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return SexoItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
    );
  }

  static List<SexoItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => SexoItemModel.fromRawString(r))
        .toList();
  }
}

class TipoParticipanteItemModel extends TipoParticipanteItem {
  const TipoParticipanteItemModel({
    required super.id,
    required super.nombre,
    required super.esInvitado,
  });

  factory TipoParticipanteItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return TipoParticipanteItemModel(
      id: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
      esInvitado: ParseUtils.toBool(c, 2),
    );
  }

  static List<TipoParticipanteItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => TipoParticipanteItemModel.fromRawString(r))
        .toList();
  }
}

class UbigeoItemModel extends UbigeoItem {
  const UbigeoItemModel({
    required super.dpto,
    required super.prov,
    required super.dis,
    required super.nombre,
  });

  factory UbigeoItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return UbigeoItemModel(
      dpto: ParseUtils.str(c, 0),
      prov: ParseUtils.str(c, 1),
      dis: ParseUtils.str(c, 2),
      nombre: ParseUtils.str(c, 3),
    );
  }

  static List<UbigeoItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => UbigeoItemModel.fromRawString(r))
        .toList();
  }
}

class CanalExpoItemModel extends CanalExpoItem {
  const CanalExpoItemModel({
    required super.id,
    required super.descripcion,
    required super.esDetallado,
  });

  factory CanalExpoItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return CanalExpoItemModel(
      id: ParseUtils.toInt(c, 0),
      descripcion: ParseUtils.str(c, 1),
      esDetallado: ParseUtils.toBool(c, 2),
    );
  }

  static List<CanalExpoItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CanalExpoItemModel.fromRawString(r))
        .toList();
  }
}
