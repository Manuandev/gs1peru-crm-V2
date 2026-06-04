// lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';

/// Estilos de Texto del Sistema de Diseño
///
/// REGLA DE ORO:
/// Los estilos BASE no llevan `color`.
/// AppTheme ya define bodyColor/displayColor en el textTheme
/// → en dark mode = blanco, en light mode = negro. Automático.
///o
/// Solo los estilos `onDark*` llevan color explícito porque se usan
/// sobre el gradiente (fuera del Card/Scaffold donde el tema no aplica).
///
/// USO:
/// Text('Título',    style: AppTextStyles.headlineMedium)   ← hereda del tema
/// Text('MI APP',    style: AppTextStyles.onDarkDisplay)    ← blanco forzado (sobre gradiente)
/// Text('botón',     style: AppTextStyles.button)           ← sin color, hereda
class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // FAMILIAS DE FUENTES
  // Para cambiar la fuente de TODA la app, edita solo aquí.
  // Recuerda declarar la fuente en pubspec.yaml primero.
  // ============================================================

  static const String fontPrimary = 'Roboto'; // Fuente principal UI
  static const String fontSecondary = 'Arial'; // Fuente alternativa
  static const String fontMono = 'RobotoMono'; // Código / IDs

  // ============================================================
  // ESCALA DE TAMAÑOS
  // Un solo lugar para cambiar todos los tamaños.
  // ============================================================

  /// Micro: 9px — texto de badge de notificaciones en AppBar
  static const double sizeXxs = 9.0;

  /// Sub: 10px — texto de apoyo muy pequeño (ej: "sin respuesta" en PrioridadTile)
  static const double sizeSub = 10.0;

  static const double sizeXs = 11.0;
  static const double sizeSm = 12.0;
  static const double sizeMd = 14.0;

  /// Intermedio entre sizeSm y sizeMd: 13px — timer elapsed en PrioridadTile
  static const double sizeSmPlus = 13.0;

  static const double sizeBase = 15.0; // Intermedio: tablet (entre sizeMd y sizeLg)
  static const double sizeLg = 16.0; // Base: inputs, botones
  static const double sizeXl = 18.0;
  static const double size2xl = 22.0;
  static const double size3xl = 28.0; // Títulos de pantalla
  static const double size4xl = 36.0;
  static const double size5xl = 40.0; // Splash display
  static const double size6xl = 48.0; // Error 404
  static const double size7xl = 57.0; // Display grande

  // ============================================================
  // PESOS DE FUENTE
  // ============================================================

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  /// Extra bold: w800 — timer de urgencia alta en PrioridadTile
  static const FontWeight weightExtraBold = FontWeight.w800;

  // ============================================================
  // ESTILOS BASE — SIN COLOR
  // El color lo inyecta AppTheme automáticamente según el modo.
  // dark mode  → colorScheme.onSurface (blanco)
  // light mode → colorScheme.textPrimary (negro)
  // ============================================================

  // --- Display ---
  static const TextStyle displayLarge = TextStyle(
    fontSize: size7xl,
    fontWeight: weightBold,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: size6xl,
    fontWeight: weightBold,
  );

  // --- Headline (títulos de pantalla) ---
  static const TextStyle headlineLarge = TextStyle(
    fontSize: size4xl,
    fontWeight: weightBold,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: size3xl,
    fontWeight: weightBold,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: size2xl,
    fontWeight: weightBold,
  );

  // --- Title ---
  static const TextStyle titleLarge = TextStyle(
    fontSize: size2xl,
    fontWeight: weightSemiBold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: sizeLg,
    fontWeight: weightSemiBold,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: sizeMd,
    fontWeight: weightSemiBold,
  );

  // --- Body ---
  static const TextStyle bodyLarge = TextStyle(
    fontSize: sizeLg,
    fontWeight: weightRegular,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: sizeMd,
    fontWeight: weightRegular,
  );

  // bodySmall lleva color secundario — pero usa colorScheme que es consistente
  static const TextStyle bodySmall = TextStyle(
    fontSize: sizeSm,
    fontWeight: weightRegular,
  );

  // --- Label ---
  static const TextStyle labelLarge = TextStyle(
    fontSize: sizeMd,
    fontWeight: weightMedium,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: sizeSm,
    fontWeight: weightMedium,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: sizeXs,
    fontWeight: weightMedium,
  );

  // ============================================================
  // ESTILOS DE INPUTS
  // Sin color → hereda del tema (blanco en dark, negro en light)
  // ============================================================

  /// Texto que escribe el usuario
  static const TextStyle inputText = TextStyle(
    fontSize: sizeLg,
    fontWeight: weightRegular,
    // SIN color → Flutter lo hereda del tema
  );

  // ============================================================
  // ESTILOS DE BOTONES
  // Sin color → el FilledButton/OutlinedButton pone el foreground
  // ============================================================

  static const TextStyle button = TextStyle(
    fontSize: sizeLg,
    fontWeight: weightBold,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: sizeLg,
    fontWeight: weightMedium,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: sizeMd,
    fontWeight: weightMedium,
  );

  // ============================================================
  // ESTILOS SOBRE GRADIENTE (onDark*)
  // Estos SÍ llevan color explícito porque van sobre el fondo
  // gradiente morado del Splash/Login, donde el tema no aplica.
  // ============================================================

  /// Nombre de la app en Splash (grande, blanco, espaciado)
  // static const TextStyle onDarkDisplay = TextStyle(
  //   fontSize: size5xl,
  //   fontWeight: weightBold,
  //   color: Colors.white,

  //   letterSpacing: 4,
  // );

  // /// Subtítulo en Splash
  // static const TextStyle onDarkSubtitle = TextStyle(
  //   fontSize: sizeXl,
  //   fontWeight: weightRegular,
  //   color: Colors.white,

  //   letterSpacing: 2,
  // );

  // /// Texto pequeño en Splash (ej: "Cargando...")
  // static const TextStyle onDarkCaption = TextStyle(
  //   fontSize: sizeMd,
  //   fontWeight: weightRegular,
  //   color: Colors.white,
  // );

  // ============================================================
  // ESTILOS PARA SNACKBAR DE ADVERTENCIA
  // El warning tiene fondo claro → texto oscuro
  // ============================================================

  static const TextStyle snackWarningText = TextStyle();

  // ============================================================
  // LETTER SPACING (Espaciado entre letras)
  // ============================================================

  /// Apretado: -0.3 — para headings grandes (evita exceso de espacio)
  static const double letterSpacingTight = -0.3;

  /// Estrecho positivo: 0.2 — labels en DashboardCard
  static const double letterSpacingXNarrow = 0.2;

  /// Estrecho positivo: 0.3 — subtítulos de CardTotalesHome
  static const double letterSpacingNarrow = 0.3;

  /// Amplio: 4.0 — título principal sobre fondo de marca (Splash / Login)
  static const double letterSpacingWide = 4.0;

  // ============================================================
  // ESTILOS DE NOTIFICACIONES (snackbars / toasts)
  // Llevan color explícito porque se usan sobre fondos oscuros
  // de la paleta snackbar (AppColors.snackXxxText), no del tema.
  // ============================================================

  /// Título de notificación: 13sp semiBold h1.3
  /// Usado en la primera línea del snackbar cuando se pasa [title]
  static const TextStyle snackTitle = TextStyle(
    fontSize: 13.0,
    fontWeight: weightSemiBold,
    height: 1.3,
  );

  /// Cuerpo de notificación: 12sp regular h1.4
  /// Texto principal del mensaje en el snackbar
  static const TextStyle snackBody = TextStyle(
    fontSize: sizeSm,
    height: 1.4,
  );
}
