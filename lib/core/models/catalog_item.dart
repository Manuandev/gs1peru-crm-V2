// lib/core/models/catalog_item.dart

import 'package:app_crm/core/index_core.dart';

class ListasGenericas {
  final List<CampaniaItem> campanias;
  final List<OportunidadItem> oportunidades;
  final List<CanalItem> canales;
  final List<InteresItem> intereses;
  // Parte [4] del SP lstListas. Vacío hasta que el SP devuelva la sección.
  final List<EstadoItem> estados;
  // Parte [5] del SP lstListas. Vacío hasta que el SP devuelva la sección.
  final List<AsesorItem> asesores;
  // Parte [6] del SP lstListas — DBO.[edu.TIP_ESTADO_GES], estados de cobranza (planos, sin padre)
  final List<EstadoGestionItem> estadosGestion;
  // Parte [7] del SP lstListas — SYSTABEXTER02 CODTABLA='MON', tipos de moneda
  final List<MonedaItem> monedas;
  // Parte [8] del SP lstListas — SYSTABEXTER02 CODTABLA='IGV' codargu='01', valor único (no es lista)
  final double igvPorcentaje;
  // Parte [9] del SP lstListas — SYSTABEXTER02 CODTABLA='CPA', países
  final List<PaisItem> paises;
  // Parte [10] del SP lstListas — SYSTABEXTER02 CODTABLA='F01', tipos de documento (id STRING)
  final List<TipoDocumentoItem> tiposDocumento;
  // Parte [11] del SP lstListas — SYSTABEXTER02 CODTABLA='DFA' (01/03/07/08), tipos de comprobante
  final List<ComprobanteItem> comprobantes;
  // Parte [12] del SP lstListas — SYSTABEXTER02 CODTABLA='NPA', nacionalidades (gentilicio, distinto de País)
  final List<NacionalidadItem> nacionalidades;

  const ListasGenericas({
    required this.campanias,
    required this.oportunidades,
    required this.canales,
    required this.intereses,
    this.estados = const [],
    this.asesores = const [],
    this.estadosGestion = const [],
    this.monedas = const [],
    this.igvPorcentaje = 0,
    this.paises = const [],
    this.tiposDocumento = const [],
    this.comprobantes = const [],
    this.nacionalidades = const [],
  });
}

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
    );
  }
}

class CampaniaItem with Comboable {
  final int id;
  final String nombre;
  const CampaniaItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

class OportunidadItem with Comboable {
  final int idEvento;
  final int idCampania;
  final String nombre;

  const OportunidadItem({
    required this.idEvento,
    required this.idCampania,
    required this.nombre,
  });

  @override
  List<dynamic> get fields => [idEvento, idCampania, nombre];
}

class OportunidadItemModel extends OportunidadItem {
  const OportunidadItemModel({
    required super.idEvento,
    required super.idCampania,
    required super.nombre,
  });

  factory OportunidadItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return OportunidadItemModel(
      idEvento: ParseUtils.toInt(c, 0),
      idCampania: ParseUtils.toInt(c, 1),
      nombre: ParseUtils.str(c, 2),
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

class CanalItem with Comboable {
  final int id;
  final String nombre;
  final String? iconoApp;
  const CanalItem({required this.id, required this.nombre, this.iconoApp});

  @override
  List<dynamic> get fields => [id, nombre];
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

class InteresItem with Comboable {
  final int id;
  final String nombre;
  const InteresItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [4]: idEstado ¦ descripcion ¦ idEstadoPadre (vacío si es padre)
class EstadoItem with Comboable {
  final String id;
  final String nombre;

  /// null → estado principal; non-null → es subestado de [idPadre].
  final String? idPadre;

  const EstadoItem({required this.id, required this.nombre, this.idPadre});

  bool get esPadre => idPadre == null || idPadre!.isEmpty;

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [5]: codUser ¦ nombre ¦ flgDisponible (0/1)
class AsesorItem with Comboable {
  final String codUser;
  final String nombre;
  final bool disponible;

  const AsesorItem({
    required this.codUser,
    required this.nombre,
    required this.disponible,
  });

  @override
  List<dynamic> get fields => [codUser, nombre];
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

// SP lstListas parte [6]: idEstadoGes ¦ descripcion — estados de cobranza, sin padre
class EstadoGestionItem with Comboable {
  final String id;
  final String nombre;

  const EstadoGestionItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

class MonedaItem with Comboable {
  // codargu del SP (SYSTABEXTER02) — id interno usado para autoseleccionar
  // el combo cuando el SP de detalle de lead mande su propio idMoneda.
  final String id;
  // valor4 del SP — código ISO ('PEN'/'USD'), usado por NumberFormatUtils.
  final String codigo;
  final String nombre;
  final String simbolo;

  const MonedaItem({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.simbolo,
  });

  @override
  List<dynamic> get fields => [id, '$codigo — $nombre'];
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

// SP lstListas parte [9]: codargu ¦ deslarga ¦ partidam — SYSTABEXTER02 CODTABLA='CPA'.
// id = codargu (país), codigoTelefono = partidam (código de marcado, ej. '51' para Perú).
// Sirve tanto para el combo "País" (id + nombre) como para el selector de código
// telefónico del celular (codigoTelefono + nombre).
class PaisItem with Comboable {
  final String id;
  final String nombre;
  final String codigoTelefono;

  const PaisItem({
    required this.id,
    required this.nombre,
    required this.codigoTelefono,
  });

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [10]: codargu ¦ deslarga — SYSTABEXTER02 CODTABLA='F01'.
// id es STRING (codargu), no int — no parsear con toInt.
class TipoDocumentoItem with Comboable {
  final String id;
  final String nombre;

  const TipoDocumentoItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [11]: codargu ¦ deslarga — SYSTABEXTER02 CODTABLA='DFA',
// filtrado a Factura(01)/Boleta de venta(03)/Nota de crédito(07)/Nota de débito(08).
class ComprobanteItem with Comboable {
  final String id;
  final String nombre;

  const ComprobanteItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [12]: codargu ¦ deslarga ¦ valor4 — SYSTABEXTER02 CODTABLA='NPA'.
// Nacionalidad (gentilicio: "PERUANO/A", "BRASILEÑO/A"...) — distinta de País (nombre de
// lugar: "PERÚ", "BRASIL"...), no confundir con [PaisItem].
class NacionalidadItem with Comboable {
  final String id;
  final String nombre;
  final String valor4;

  const NacionalidadItem({
    required this.id,
    required this.nombre,
    required this.valor4,
  });

  @override
  List<dynamic> get fields => [id, nombre];
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
