// lib/core/database/local_database.dart
// ============================================================
// BASE DE DATOS LOCAL — SQLITE con sqflite
// ============================================================
//
// TABLAS:
// - session → guarda la sesión del usuario autenticado
//
// CÓMO AGREGAR UNA TABLA NUEVA:
// 1. Agrega el CREATE TABLE en _onCreate
// 2. Si ya existe la app y necesitas migrar, usa _onUpgrade
//    incrementando el número de versión
// ============================================================

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'i_local_database.dart';

class LocalDatabase implements ILocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _database;

  /// Instancia de la BD. Lanza error si no fue inicializada.
  Database get _db {
    if (_database == null) {
      throw StateError(
        'LocalDatabase no inicializada. '
        'Llama await LocalDatabase().init() en main.dart antes de runApp().',
      );
    }
    return _database!;
  }

  // ── INICIALIZACIÓN ───────────────────────────────────────

  @override
  Future<void> init() async {
    if (_database != null) return; // ya inicializada

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_crm.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea todas las tablas la primera vez que se instala la app.
  Future<void> _onCreate(Database db, int version) async {
    // ── TABLA: session ───────────────────────────────────
    await db.execute('''
      CREATE TABLE session (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        login_type TEXT NOT NULL,
        username   TEXT,
        password   TEXT,
        email      TEXT,
        expires_at TEXT NOT NULL
      )
    ''');
    // await db.execute('''
    //   CREATE TABLE session (
    //     id             INTEGER PRIMARY KEY AUTOINCREMENT,
    //     user_id        TEXT NOT NULL,
    //     username       TEXT NOT NULL,
    //     token          TEXT NOT NULL,
    //     raw_user       TEXT,
    //     raw_pass       TEXT,
    //     cod_user       TEXT,
    //     user_ape       TEXT,
    //     tipo_user      TEXT,
    //     carg_user      TEXT,
    //     correo_user    TEXT,
    //     telefono       TEXT,
    //     anexo          TEXT,
    //     celular        TEXT,
    //     disponibilidad TEXT,
    //     id_tipouser    TEXT,
    //     expires_at     TEXT NOT NULL
    //   )
    // ''');

    // Todo: agrega más tablas aquí cuando las necesites
    // Ejemplo:
    // await db.execute('''
    //   CREATE TABLE leads (
    //     id        INTEGER PRIMARY KEY AUTOINCREMENT,
    //     id_lead   TEXT NOT NULL,
    //     nombre    TEXT,
    //     ...
    //   )
    // ''');
  }

  /// Migración cuando sube la versión de la BD.
  /// Incrementa el número en openDatabase → version: X
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Todo: agrega migraciones aquí si cambias tablas
    // Ejemplo: si en versión 2 agregas columna 'cargo' a session:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE session ADD COLUMN cargo TEXT');
    // }
  }

  // ── OPERACIONES GENÉRICAS ────────────────────────────────

  /// Inserta o actualiza un registro.
  /// Usa REPLACE INTO (borra + inserta) si ya existe el mismo id.
  @override
  Future<void> upsert(String table, Map<String, dynamic> data) async {
    await _db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Obtiene un registro por su campo 'id'.
  @override
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final results = await _db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Obtiene todos los registros de una tabla.
  @override
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    return _db.query(table);
  }

  /// Elimina un registro por su campo 'id'.
  @override
  Future<void> delete(String table, String id) async {
    await _db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina todos los registros de una tabla.
  @override
  Future<void> clearTable(String table) async {
    await _db.delete(table);
  }

  // ── OPERACIONES ESPECÍFICAS (helpers) ────────────────────

  /// Busca un registro con condición personalizada.
  /// Ejemplo: getWhere('session', 'user_id = ?', ['123'])
  Future<Map<String, dynamic>?> getWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final results = await _db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Ejecuta una query SQL personalizada (para casos complejos).
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    return _db.rawQuery(sql, args);
  }
}
