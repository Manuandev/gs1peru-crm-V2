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

class CampaniaItem with Comboable {
  final int id;
  final String nombre;
  const CampaniaItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
}

class OportunidadItem with Comboable {
  final int id;
  final int idCampania;
  final String nombre;
  final String idMoneda;
  final double importeGeneral;
  final double importeAsociado;

  const OportunidadItem({
    required this.id,
    required this.idCampania,
    required this.nombre,
    required this.idMoneda,
    required this.importeGeneral,
    required this.importeAsociado,
  });

  @override
  List<dynamic> get fields => [id, idCampania, nombre];
}

class CanalItem with Comboable {
  final int id;
  final String nombre;
  final String? iconoApp;
  const CanalItem({required this.id, required this.nombre, this.iconoApp});

  @override
  List<dynamic> get fields => [id, nombre];
}

class InteresItem with Comboable {
  final int id;
  final String nombre;
  const InteresItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [6]: idEstadoGes ¦ descripcion — estados de cobranza, sin padre
class EstadoGestionItem with Comboable {
  final String id;
  final String nombre;

  const EstadoGestionItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
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

// SP lstListas parte [10]: codargu ¦ deslarga — SYSTABEXTER02 CODTABLA='F01'.
// id es STRING (codargu), no int — no parsear con toInt.
class TipoDocumentoItem with Comboable {
  final String id;
  final String nombre;

  const TipoDocumentoItem({required this.id, required this.nombre});

  // El SP solo trae la descripción larga (ej. "DOC. NACIONAL DE IDENTIDAD").
  // La UI necesita la forma abreviada (DNI/CE/RUC/...) — no viene del backend,
  // se mapea acá por id (mismos ids reales de SYSTABEXTER02 CODTABLA='F01').
  static const Map<String, String> _abreviaturas = {
    '0': 'Doc. sin RUC',
    '1': 'DNI',
    '4': 'CE',
    '6': 'RUC',
    '7': 'Pasaporte',
    'A': 'Céd. Diplomática',
  };

  String get abreviatura => _abreviaturas[id] ?? nombre;

  @override
  List<dynamic> get fields => [id, nombre, abreviatura];
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

// SP lstListas parte [13]: id
// Valores por defecto en CRM: pais, moneda, nacionalidad, etc.
class ValoresCRMItem with Comboable {
  final int idCanalWsp;
  final String idPais;
  final String idNacionalidad;
  final String idEstadoNuevo;
  final String idEstadoGanado;
  final String idTipoBoleta;
  final String idTipoFactura;
  final String idTipoDocRuc;
  final String idTipoDocSnd;
  final String idTipoDocDni;
  final String idTipoDocCde;
  final String idTipoDocPas;

  const ValoresCRMItem({
    this.idCanalWsp = 0,
    this.idPais = '',
    this.idNacionalidad = '',
    this.idEstadoNuevo = '',
    this.idEstadoGanado = '',
    this.idTipoBoleta = '',
    this.idTipoFactura = '',
    this.idTipoDocRuc = '',
    this.idTipoDocSnd = '',
    this.idTipoDocDni = '',
    this.idTipoDocCde = '',
    this.idTipoDocPas = '',
  });

  @override
  List<dynamic> get fields => [
    idCanalWsp,
    idPais,
    idNacionalidad,
    idEstadoNuevo,
    idEstadoGanado,
    idTipoBoleta,
    idTipoFactura,
    idTipoDocRuc,
    idTipoDocSnd,
    idTipoDocDni,
    idTipoDocCde,
    idTipoDocPas,
  ];
}
