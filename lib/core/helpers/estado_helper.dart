// lib/core/helpers/estado_helper.dart

import 'package:flutter/material.dart';

class EstadoInfo {
  final String nombre;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const EstadoInfo({
    required this.nombre,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class EstadoHelper {
  EstadoHelper._();

  static const Map<int, EstadoInfo> _data = {
    0: EstadoInfo(
      nombre: 'Nuevo',
      icon: Icons.notifications_outlined,   // ✅ campana igual que web
      color: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
    1: EstadoInfo(
      nombre: 'En desarrollo',
      icon: Icons.trending_up,              // ✅ gráfica igual que web
      color: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
    ),
    2: EstadoInfo(
      nombre: 'Propuesta',
      icon: Icons.bar_chart,               // ✅ barras igual que web
      color: Color(0xFF6A1B9A),
      bgColor: Color(0xFFF3E5F5),
    ),
    3: EstadoInfo(
      nombre: 'Ficha',
      icon: Icons.badge_outlined,
      color: Color(0xFF00695C),
      bgColor: Color(0xFFE0F2F1),
    ),
    4: EstadoInfo(
      nombre: 'Cerrado',
      icon: Icons.visibility_outlined,     // ✅ ojo igual que web
      color: Color(0xFF37474F),
      bgColor: Color(0xFFECEFF1),
    ),
    5: EstadoInfo(
      nombre: 'Evaluando información',
      icon: Icons.search_outlined,
      color: Color(0xFFE65100),
      bgColor: Color(0xFFFFF3E0),
    ),
    7: EstadoInfo(
      nombre: 'Estado de prueba',
      icon: Icons.science_outlined,
      color: Color(0xFF558B2F),
      bgColor: Color(0xFFF1F8E9),
    ),
    8: EstadoInfo(
      nombre: 'Pendiente',
      icon: Icons.hourglass_empty_outlined,
      color: Color(0xFFF57F17),
      bgColor: Color(0xFFFFFDE7),
    ),
    9: EstadoInfo(
      nombre: 'Sin respuesta',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFFAD1457),
      bgColor: Color(0xFFFCE4EC),
    ),
    10: EstadoInfo(
      nombre: 'Desiste',
      icon: Icons.remove_circle_outline,
      color: Color(0xFFB71C1C),
      bgColor: Color(0xFFFFEBEE),
    ),
    11: EstadoInfo(
      nombre: 'Ganado',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFF1B5E20),
      bgColor: Color(0xFFE8F5E9),
    ),
    12: EstadoInfo(
      nombre: 'Perdido',
      icon: Icons.sentiment_dissatisfied_outlined,
      color: Color(0xFF880E4F),
      bgColor: Color(0xFFFCE4EC),
    ),
    13: EstadoInfo(
      nombre: 'Próximo periodo',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFF004D40),
      bgColor: Color(0xFFE0F2F1),
    ),
    14: EstadoInfo(
      nombre: 'No tiene WhatsApp',
      icon: Icons.speaker_phone,
      color: Color(0xFF4E342E),
      bgColor: Color(0xFFEFEBE9),
    ),
    15: EstadoInfo(
      nombre: 'Solicitó ficha',
      icon: Icons.assignment_outlined,
      color: Color(0xFF0D47A1),
      bgColor: Color(0xFFE3F2FD),
    ),
  };

  static EstadoInfo get(int id) =>
      _data[id] ??
      const EstadoInfo(
        nombre: 'Desconocido',
        icon: Icons.help_outline,
        color: Color(0xFF9E9E9E),
        bgColor: Color(0xFFF5F5F5),
      );

  /// Chip listo para usar en cualquier widget
  static Widget chip(int id, {TextStyle? textStyle}) {
    final info = get(id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: info.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 11, color: info.color),
          const SizedBox(width: 4),
          Text(
            info.nombre,
            style: (textStyle ?? const TextStyle()).copyWith(
              color: info.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Solo el ícono
  static Widget icon(int id, {double size = 16}) {
    final info = get(id);
    return Icon(info.icon, color: info.color, size: size);
  }
}