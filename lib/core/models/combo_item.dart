// lib\core\models\combo_item.dart

/// Modelo compartido para todos los tipos de combo.
///
/// Soporta cualquier cantidad de campos separados por [separator] (¦ por defecto).
///
/// Estructura esperada (mínimo 2 campos):
///   id¦descripcion¦value1¦value2¦value3¦...¦valueN
///
/// Acceso rápido:
///   item.id            → primer campo  (índice 0)
///   item.descripcion   → segundo campo (índice 1)
///   item.value(2)      → tercer campo  (índice 2, nullable)
///   item.value(3)      → cuarto campo  (índice 3, nullable)
///   item['2']          → igual que item.value(2), acceso tipo mapa
///
/// Ejemplo con 5 campos:
///   "001¦Gerente¦GER¦Nivel3¦Activo"
///   item.id          → "001"
///   item.descripcion → "Gerente"
///   item.value(2)    → "GER"
///   item.value(3)    → "Nivel3"
///   item.value(4)    → "Activo"
class ComboItem {
  /// Siempre presente: primer campo.
  final String id;
  /// Siempre presente: segundo campo.
  final String descripcion;
  /// Campos adicionales (índice 2 en adelante), pueden ser vacíos.
  final List<String> _extra;

  const ComboItem._({
    required this.id,
    required this.descripcion,
    required List<String> extra,
  }) : _extra = extra;

  // ── Constructor público ──────────────────────────────────────────────────
  factory ComboItem({
    required String id,
    required String descripcion,
    List<String> extra = const [],
  }) =>
      ComboItem._(id: id, descripcion: descripcion, extra: extra);

  // ── Acceso por índice (0-based) ──────────────────────────────────────────
  /// Retorna el campo en la posición [index] (0-based).
  ///   0 → id
  ///   1 → descripcion
  ///   2+ → campos extra (nullable si no existe)
  String? field(int index) {
    if (index == 0) return id;
    if (index == 1) return descripcion;
    final i = index - 2;
    return (i >= 0 && i < _extra.length) ? _extra[i] : null;
  }

  /// Alias legible para acceder a campos extra por índice (2 en adelante).
  /// Ejemplo: item.value(2), item.value(3)
  String? value(int index) => field(index);

  /// Total de campos que tiene este item.
  int get fieldCount => 2 + _extra.length;

  /// Todos los campos como lista.
  List<String?> get fields => [
        id,
        descripcion,
        ..._extra,
      ];

  // ── Parseo ───────────────────────────────────────────────────────────────
  /// Parsea un String crudo "id¦desc¦v1¦v2¦..." en un [ComboItem].
  factory ComboItem.fromRaw(String raw, {String separator = '¦'}) {
    final parts = raw.split(separator).map((e) => e.trim()).toList();
    return ComboItem._(
      id:          parts.isNotEmpty ? parts[0] : '',
      descripcion: parts.length > 1 ? parts[1] : '',
      extra:       parts.length > 2 ? parts.sublist(2) : const [],
    );
  }

  /// Convierte una lista de strings crudos en lista de [ComboItem].
  static List<ComboItem> fromList(
    List<String> data, {
    String separator = '¦',
  }) =>
      data
          .where((e) => e.trim().isNotEmpty)
          .map((e) => ComboItem.fromRaw(e, separator: separator))
          .toList();

  // ── Igualdad basada en id ────────────────────────────────────────────────
  @override
  bool operator ==(Object other) => other is ComboItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ComboItem(id: $id, descripcion: $descripcion, extra: $_extra)';
}