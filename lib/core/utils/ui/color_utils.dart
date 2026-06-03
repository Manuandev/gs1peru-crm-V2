import 'package:flutter/material.dart';

/// Utilidades de color para generar colores consistentes y legibles
/// tanto en modo claro como oscuro.
class ColorUtils {
  ColorUtils._(); // no instanciable

  // ─── Colores fijos por label (dashboard principal) ────────────
  static const Map<String, Color> _labelColors = {
    // Conversaciones
    'Mis conversaciones': Color(0xFF2196F3),
    'Conversaciones': Color(0xFF2196F3),
    // Prospectos
    'Prospectos': Color(0xFF4CAF50),
    'Prospecto': Color(0xFF4CAF50),
    // Propuesta / Propuestas
    'Propuesta': Color(0xFFF26334),
    'Propuestas': Color(0xFFF26334),
    // Cobranza
    'Cobranza': Color(0xFF9C27B0),
  };

  // ─── Paleta amplia (tonos medios: ni muy claros ni muy oscuros) ───
  // Luminosidad entre ~0.30 y ~0.55 para que el texto blanco siempre
  // sea legible sobre el fondo, y el color se distinga en modo oscuro.
  static const List<Color> _palette = [
    Color(0xFF1976D2), // azul
    Color(0xFF388E3C), // verde
    Color(0xFFC62828), // rojo oscuro
    Color(0xFF7B1FA2), // morado
    Color(0xFFE65100), // naranja quemado
    Color(0xFF00838F), // cyan oscuro
    Color(0xFF5D4037), // marrón
    Color(0xFF37474F), // gris azulado
    Color(0xFF6A1B9A), // púrpura
    Color(0xFF2E7D32), // verde bosque
    Color(0xFFAD1457), // rosa oscuro
    Color(0xFF0277BD), // azul acero
    Color(0xFF4527A0), // índigo
    Color(0xFF00695C), // teal oscuro
    Color(0xFF558B2F), // verde lima oscuro
    Color(0xFF8E24AA), // violeta
    Color(0xFF283593), // azul noche
    Color(0xFFBF360C), // rojo ladrillo
    Color(0xFF006064), // petróleo
    Color(0xFF4E342E), // café oscuro
  ];

  /// Color fijo si existe en el mapa, si no usa hash sobre la paleta.
  static Color fromName(String nombre) {
    final fijo = _labelColors[nombre.trim()];
    if (fijo != null) return fijo;

    if (nombre.trim().isEmpty) return _palette[0];
    int hash = 0;
    for (int i = 0; i < nombre.length; i++) {
      hash = (hash * 31 + nombre.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return _palette[hash % _palette.length];
  }

  /// Color del badge: mismo color del card con overlay negro al 25%.
  static Color badgeColor(Color base) {
    return Color.alphaBlend(Colors.black.withValues(alpha: 0.25), base);
  }

  /// Color de texto óptimo (blanco o negro) según el brillo del fondo.
  static Color textColorOn(Color fondo) {
    final luminance = fondo.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  /// Versión suave del color para fondos de tarjetas.
  static Color softBackground(String nombre, Brightness brightness) {
    final base = fromName(nombre);
    if (brightness == Brightness.dark) {
      return Color.alphaBlend(base.withAlpha(50), const Color(0xFF1E1E1E));
    }
    return Color.alphaBlend(base.withAlpha(35), Colors.white);
  }
}