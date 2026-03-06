// lib/core/theme/theme_cubit.dart
// ============================================================
// THEME CUBIT — Persiste el tema en SQLite (LocalDatabase)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/core/database/local_database.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme';
  final LocalDatabase _db = LocalDatabase();

  ThemeCubit() : super(ThemeMode.system);

  /// Carga la preferencia guardada al iniciar la app.
  /// Llama esto en main() con await antes de runApp().
  Future<void> loadSavedTheme() async {
    final saved = await _db.getSetting(_key);
    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  /// Cambia el tema y lo persiste en SQLite.
  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final value = switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    };
    await _db.setSetting(_key, value);
  }
}