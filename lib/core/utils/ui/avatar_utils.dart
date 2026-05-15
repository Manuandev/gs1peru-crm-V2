import 'package:flutter/material.dart';

class AvatarUtils {
  AvatarUtils._(); // no instanciable

  // ─── Paleta de colores ────────────────────────────────────────
  static const List<Color> _colors = [
    Color(0xFF1976D2), // azul
    Color(0xFF388E3C), // verde
    Color(0xFFD32F2F), // rojo
    Color(0xFF7B1FA2), // morado
    Color(0xFFF57C00), // naranja
    Color(0xFF0097A7), // cyan
    Color(0xFF5D4037), // marrón
    Color(0xFF455A64), // gris azulado
  ];

  /// Retorna las iniciales de un nombre.
  /// "Juan Pérez" → "JP" | "Ana" → "A" | "" → "?"
  static String initials(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  /// Retorna un color consistente basado en el nombre.
  static Color color(String nombre) {
    final index = nombre.isNotEmpty
        ? nombre.codeUnitAt(0) % _colors.length
        : 0;
    return _colors[index];
  }
}