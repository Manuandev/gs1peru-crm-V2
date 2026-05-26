// lib\features\home\data\models\home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeModel extends Home {
  const HomeModel({
    required super.totConversaciones,
    required super.totProspectos,
    required super.totPropuestas,
    required super.totCobranza,
    required super.prioridades,
  });

  /// Parsea la respuesta completa del SP.
  ///
  /// Formato esperado:
  /// ```
  /// totConv¦totProsp¦totProp¦totCobr¯priori1_f0¦f1¦...¬priori2_f0¦f1¦...
  /// ```
  /// - `¯` (sepListas) separa totales de la lista de prioridades
  /// - `¦` (sepCampos) separa cada campo
  /// - `¬` (sepRegistros) separa cada prioridad
  static HomeModel parse(String rawResponse) {
    // 1) Separar totales de prioridades por '¯'
    final partes = rawResponse.split(AppConstants.sepListas);
    final totalesRaw = partes.isNotEmpty ? partes[0] : '';
    final prioridadesRaw = partes.length > 1 ? partes[1] : '';

    // 2) Parsear totales
    final campos = totalesRaw.split(AppConstants.sepCampos);
    int t(int i) {
      if (i >= campos.length) return 0;
      final v = campos[i].trim();
      return v.isEmpty ? 0 : int.tryParse(v) ?? 0;
    }

    // 3) Parsear lista de prioridades
    final prioridades = prioridadesRaw.trim().isEmpty
        ? <PrioridadModel>[]
        : PrioridadModel.parseList(prioridadesRaw);

    return HomeModel(
      totConversaciones: t(0),
      totProspectos: t(1),
      totPropuestas: t(2),
      totCobranza: t(3),
      prioridades: prioridades,
    );
  }
}
