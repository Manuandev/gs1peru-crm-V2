// lib/main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/app_widget.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';

// ✅ TOP-LEVEL obligatorio — debe estar fuera del main
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) =>
    firebaseMessagingBackgroundHandler(message);

// Confía en el certificado intermedio que el servidor no manda en el
// handshake TLS — sin esto, Android con parches de seguridad desactualizados
// no arma la cadena de confianza y el socket SignalR nunca conecta (ver
// signalr_service.dart). Falla en silencio si el .crt aún no fue colocado en
// assets/certs/ (ver assets/certs/README.md) — estado transitorio mientras
// se consigue el archivo real, no debe bloquear el arranque de la app.
Future<void> _confiarEnCertificadoIntermedio() async {
  try {
    final bytes = await rootBundle.load(EnvConfig.certificadoConfianza);
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      bytes.buffer.asUint8List(),
    );
  } catch (e) {
    debugPrint('[TLS] No se pudo cargar el certificado de confianza: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _confiarEnCertificadoIntermedio();

  // ── FIREBASE — primero siempre ───────────────────────────────
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // ── NOTIFICACIONES ───────────────────────────────────────────
  // await NotificationService.instance.initBackground();
  await NotificationService.instance.init();

  await DateFormatter.initialize(locale: 'es');

  // ── INICIALIZAR SQLITE ───────────────────────────────────
  // Crea app_crm.db y las tablas si no existen.
  // Si ya existen, no hace nada.
  await LocalDatabase().init();

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '948850885270-53j8a453k72iiqt38693tvqd3cs869l2.apps.googleusercontent.com',
  );

  // ✅ Cargar tema guardado antes de renderizar
  final themeCubit = ThemeCubit();
  await themeCubit.loadSavedTheme();

  // ✅ Empieza a recolectar info del dispositivo en segundo plano
  // SIN await — no bloquea nada, corre mientras el usuario ve el splash/login
  DeviceInfoService.precargarEnBackground();
  // ✅ Pide permisos de notificación en segundo plano — no bloquea
  // NotificationService.instance.requestPermissions();

  runApp(AppWidget(themeCubit: themeCubit));
}
