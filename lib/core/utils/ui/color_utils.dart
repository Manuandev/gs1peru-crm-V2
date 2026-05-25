import 'package:flutter/material.dart';

/// Utilidades de color para generar colores consistentes y legibles
/// tanto en modo claro como oscuro.
class ColorUtils {
  ColorUtils._(); // no instanciable

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

  /// Retorna un color consistente basado en el [nombre].
  /// Usa un hash simple para distribuir mejor los colores.
  static Color fromName(String nombre) {
    if (nombre.trim().isEmpty) return _palette[0];
    // Hash simple con todos los caracteres para mejor distribución
    int hash = 0;
    for (int i = 0; i < nombre.length; i++) {
      hash = (hash * 31 + nombre.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return _palette[hash % _palette.length];
  }

  /// Color de texto óptimo (blanco o negro) según el brillo del [fondo].
  /// Útil cuando necesitas poner texto sobre un color generado.
  static Color textColorOn(Color fondo) {
    // Fórmula de luminancia relativa (WCAG)
    final luminance = fondo.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  /// Versión suave del color para usar como fondo en tarjetas,
  /// adaptada al [brightness] actual del tema (claro/oscuro).
  static Color softBackground(String nombre, Brightness brightness) {
    final base = fromName(nombre);
    if (brightness == Brightness.dark) {
      // En modo oscuro: fondo con baja opacidad sobre superficie oscura
      return Color.alphaBlend(base.withAlpha(50), const Color(0xFF1E1E1E));
    }
    // En modo claro: tinte suave
    return Color.alphaBlend(base.withAlpha(35), Colors.white);
  }
}
