// lib\main.dart

import 'package:app_crm/core/notifications/index_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:app_crm/app_widget.dart';
import 'package:app_crm/core/index_core.dart';

// ✅ TOP-LEVEL obligatorio — debe estar fuera del main
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) =>
    firebaseMessagingBackgroundHandler(message);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── FIREBASE — primero siempre ───────────────────────────────
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // ── NOTIFICACIONES ───────────────────────────────────────────
  await NotificationService.instance.init();

  await DateFormatter.initialize(locale: 'es');

  // ── INICIALIZAR SQLITE ───────────────────────────────────
  // Crea app_crm.db y las tablas si no existen.
  // Si ya existen, no hace nada.
  await LocalDatabase().init();

  // v7: initialize obligatorio antes de cualquier uso
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '1090773672718-buupi5ospput8t9dv861eqfchvthh9rs.apps.googleusercontent.com',
  );

  // ✅ Cargar tema guardado antes de renderizar
  final themeCubit = ThemeCubit();
  await themeCubit.loadSavedTheme();

  // ✅ Empieza a recolectar info del dispositivo en segundo plano
  // SIN await — no bloquea nada, corre mientras el usuario ve el splash/login
  DeviceInfoService.precargarEnBackground();

  runApp(AppWidget(themeCubit: themeCubit));
}
