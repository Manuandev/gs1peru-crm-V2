// lib/core/models/catalog_item.dart

import 'package:app_crm/core/index_core.dart';

class ListasGenericas {
  final List<CampaniaItem> campanias;
  final List<OportunidadItem> oportunidades;
  final List<CanalItem> canales;
  final List<InteresItem> intereses;

  const ListasGenericas({
    required this.campanias,
    required this.oportunidades,
    required this.canales,
    required this.intereses,
  });
}

class ListasGenericasModel extends ListasGenericas {
  const ListasGenericasModel({
    required super.campanias,
    required super.oportunidades,
    required super.canales,
    required super.intereses,
  });

  static ListasGenericasModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final campaniasRaw = partes.isNotEmpty ? partes[0] : '';
    final oportunidadesRaw = partes.length > 1 ? partes[1] : '';
    final canalesRaw = partes.length > 2 ? partes[2] : '';
    final interesesRaw = partes.length > 3 ? partes[3] : '';

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

    return ListasGenericasModel(
      campanias: campanias,
      oportunidades: oportunidades,
      canales: canales,
      intereses: intereses,
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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return CampaniaItemModel(id: int.parse(f(0)), nombre: f(1));
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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return OportunidadItemModel(
      idEvento: int.parse(f(0)),
      idCampania: int.parse(f(1)),
      nombre: f(2),
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
  const CanalItem({required this.id, required this.nombre});

  @override
  List<dynamic> get fields => [id, nombre];
}

class CanalItemModel extends CanalItem {
  const CanalItemModel({required super.id, required super.nombre});

  factory CanalItemModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return CanalItemModel(id: int.parse(f(0)), nombre: f(1));
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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return InteresItemModel(id: int.parse(f(0)), nombre: f(1));
  }

  static List<InteresItemModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => InteresItemModel.fromRawString(r))
        .toList();
  }
}
