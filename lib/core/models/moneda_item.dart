// lib/core/models/moneda_item.dart

import 'package:app_crm/core/mixins/comboable.dart';

class MonedaItem with Comboable {
  final String codigo;
  final String nombre;
  final String simbolo;

  const MonedaItem({
    required this.codigo,
    required this.nombre,
    required this.simbolo,
  });

  @override
  List<dynamic> get fields => [codigo, '$codigo — $nombre'];
}
