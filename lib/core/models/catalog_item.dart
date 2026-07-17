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
  // Parte [13] del SP lstListas — fila única con IDs por defecto (canal, país,
  // nacionalidad, estados, tipo de boleta/factura, tipos de documento)
  final ValoresCRMItem valoresDefecto;
  // Parte [14] del SP lstListas — hardcodeado (M/F/PD), tipos de sexo
  final List<SexoItem> sexos;
  // Parte [15] del SP lstListas — hardcodeado, tipos de participante de solicitudes
  final List<TipoParticipanteItem> tiposParticipante;
  // Parte [16] del SP lstListas — DBO.SYSTABUBIGEO01, departamento/provincia/distrito
  final List<UbigeoItem> ubigeo;
  // Parte [17] del SP lstListas — DBO.EDU_CANAL_EXPO, canales de expo
  final List<CanalExpoItem> canalesExpo;

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
    this.valoresDefecto = const ValoresCRMItem(),
    this.sexos = const [],
    this.tiposParticipante = const [],
    this.ubigeo = const [],
    this.canalesExpo = const [],
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
    '0': 'Sin documento',
    '1': 'DNI',
    '4': 'Carnet de extranjería',
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

// SP lstListas parte [13]: fila única (sin @sepRegistro) con los IDs por
// defecto que usa el CRM para preseleccionar combos — idCanalWsp ¦ idPais ¦
// idNacionalidad ¦ idEstadoNuevo ¦ idEstadoGanado ¦ idTipoBoleta ¦
// idTipoFactura ¦ idTipoDocRuc ¦ idTipoDocSnd ¦ idTipoDocDni ¦ idTipoDocCde ¦
// idTipoDocPas. No implementa Comboable: no es un ítem de lista/dropdown,
// es un solo bloque de valores fijos.
class ValoresCRMItem {
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
  final String idEstadoEnDesarrollo;
  final String idEstadoConPropuesta;

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
    this.idEstadoEnDesarrollo = '',
    this.idEstadoConPropuesta = '',
  });
}

// SP lstListas parte [14]: id ¦ nombre — hardcodeado en el SP (M/F/PD).
class SexoItem with Comboable {
  final String id;
  final String nombre;

  const SexoItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
}

// SP lstListas parte [15]: id ¦ nombre ¦ esInvitado(0/1) — hardcodeado en el SP.
// esInvitado=true → '2' Invitado / '3' Invitado auspicio (no paga); false → '1'
// Pagante / '4' Online. Reemplaza el chequeo `id == '2' || id == '3'` que hace
// `solicitudes/` para la regla "saltar Facturación si nadie paga".
class TipoParticipanteItem with Comboable {
  final String id;
  final String nombre;
  final bool esInvitado;

  const TipoParticipanteItem({
    required this.id,
    required this.nombre,
    required this.esInvitado,
  });

  @override
  List<dynamic> get fields => [id, nombre];
}

// SP lstListas parte [16]: dpto ¦ prov ¦ dis ¦ nombre — DBO.SYSTABUBIGEO01.
// Jerárquico (departamento > provincia > distrito): filtrar por [dpto] para el
// combo de departamento, por [dpto]+[prov] para el de provincia; [codigo] (los
// 3 juntos) identifica un distrito único para el combo final.
// Patrón ubigeo estándar de Perú para distinguir el nivel de una fila:
//   prov=='00' && dis=='00' → es un departamento
//   prov!='00' && dis=='00' → es una provincia
//   prov!='00' && dis!='00' → es un distrito
class UbigeoItem with Comboable {
  final String dpto;
  final String prov;
  final String dis;
  final String nombre;

  const UbigeoItem({
    required this.dpto,
    required this.prov,
    required this.dis,
    required this.nombre,
  });

  String get codigo => '$dpto$prov$dis';

  @override
  List<dynamic> get fields => [codigo, nombre];
}

// SP lstListas parte [17]: idCanal ¦ descripcion ¦ esDetallado — dbo.EDU_CANAL_EXPO.
class CanalExpoItem with Comboable {
  final int id;
  final String descripcion;
  final bool esDetallado;

  const CanalExpoItem({
    required this.id,
    required this.descripcion,
    required this.esDetallado,
  });

  @override
  List<dynamic> get fields => [id, descripcion];
}
