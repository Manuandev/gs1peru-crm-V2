/// Contrato de base de datos local.
/// 
/// IMPLEMENTACIONES POSIBLES:
/// - SQLite  → usar [sqflite] package
/// - Hive    → usar [hive] package
/// - Isar    → usar [isar] package
///
/// PARA IMPLEMENTAR:
/// 1. Crea tu clase en [local_database.dart]
/// 2. Implementa esta interfaz
/// 3. Regístrala en [injection_container.dart]
abstract class ILocalDatabase {
  /// Inicializa la base de datos.
  /// Llamar una vez en [main.dart] antes de runApp.
  Future<void> init();

  /// Inserta o actualiza un registro.
  Future<void> upsert(String table, Map<String, dynamic> data);

  /// Obtiene un registro por id.
  Future<Map<String, dynamic>?> getById(String table, String id);

  /// Obtiene todos los registros de una tabla.
  Future<List<Map<String, dynamic>>> getAll(String table);

  /// Elimina un registro.
  Future<void> delete(String table, String id);

  /// Limpia toda una tabla.
  Future<void> clearTable(String table);
}