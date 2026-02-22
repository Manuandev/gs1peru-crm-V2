// lib\main.dart

import 'package:flutter/material.dart';
import 'package:app_crm/app_widget.dart';
import 'package:app_crm/core/database/local_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INICIALIZAR SQLITE ───────────────────────────────────
  // Crea app_crm.db y las tablas si no existen.
  // Si ya existen, no hace nada.
  await LocalDatabase().init();

  // v7: initialize obligatorio antes de cualquier uso
  await GoogleSignIn.instance.initialize(serverClientId: '1090773672718-buupi5ospput8t9dv861eqfchvthh9rs.apps.googleusercontent.com');

  runApp(const AppWidget());
}
