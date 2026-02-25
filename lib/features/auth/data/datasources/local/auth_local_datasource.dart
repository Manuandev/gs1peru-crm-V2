// lib/features/auth/data/datasources/local/auth_local_datasource.dart
// ============================================================
// AUTH - DATASOURCE LOCAL — SQLITE
// ============================================================
//
// Guarda y lee la sesión en la tabla 'session' de SQLite.
// Usa LocalDatabase (singleton) que ya está en core/database.
// ============================================================

import 'package:app_crm/core/database/local_database.dart';
import 'package:app_crm/features/auth/data/models/session_model.dart';

class AuthLocalDatasource {
  // Usa el singleton de LocalDatabase — no necesita inyección
  final LocalDatabase _db = LocalDatabase();

  static const String _table = 'session';

  /// Lee la sesión guardada desde SQLite.
  /// Retorna null si no existe ninguna sesión.
  Future<SessionModel?> getStoredSession() async {
    // La tabla session solo tiene un registro (la sesión activa)
    final results = await _db.getAll(_table);
    if (results.isEmpty) return null;
    return SessionModel.fromMap(results.first);
  }

  /// Guarda la sesión en SQLite tras un login exitoso.
  /// Limpia primero para asegurarse que solo exista una sesión.
  Future<void> saveSession(SessionModel session) async {
    // Borra sesión anterior si existe
    await _db.clearTable(_table);
    // Inserta la nueva sesión
    await _db.upsert(_table, session.toMap());
  }

  /// Limpia la sesión al hacer logout.
  Future<void> clearSession() async {
    await _db.clearTable(_table);
  }
}
