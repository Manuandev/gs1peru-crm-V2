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

  const ListasGenericas({
    required this.campanias,
    required this.oportunidades,
    required this.canales,
    required this.intereses,
    this.estados = const [],
    this.asesores = const [],
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
  });

  static ListasGenericasModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final campaniasRaw    = partes.isNotEmpty    ? partes[0] : '';
    final oportunidadesRaw = partes.length > 1   ? partes[1] : '';
    final canalesRaw      = partes.length > 2    ? partes[2] : '';
    final interesesRaw    = partes.length > 3    ? partes[3] : '';
    final estadosRaw      = partes.length > 4    ? partes[4] : '';
    final asesoresRaw     = partes.length > 5    ? partes[5] : '';

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

    return ListasGenericasModel(
      campanias: campanias,
      oportunidades: oportunidades,
      canales: canales,
      intereses: intereses,
      estados: estados,
      asesores: asesores,
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
    return CampaniaItemModel(id: ParseUtils.toInt(c, 0), nombre: ParseUtils.str(c, 1));
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
      idEvento:   ParseUtils.toInt(c, 0),
      idCampania: ParseUtils.toInt(c, 1),
      nombre:     ParseUtils.str(c, 2),
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
  const CanalItemModel({required super.id, required super.nombre, super.iconoApp});

  factory CanalItemModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return CanalItemModel(
      id:       ParseUtils.toInt(c, 0),
      nombre:   ParseUtils.str(c, 1),
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
    return InteresItemModel(id: ParseUtils.toInt(c, 0), nombre: ParseUtils.str(c, 1));
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
  final String  id;
  final String  nombre;
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
      id:      ParseUtils.str(c, 0),
      nombre:  ParseUtils.str(c, 2),
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
      codUser:    ParseUtils.str(c, 0),
      nombre:     ParseUtils.str(c, 1),
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
