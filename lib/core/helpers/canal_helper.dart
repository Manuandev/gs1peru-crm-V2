// lib/core/helpers/canal_helper.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CanalInfo {
  final String nombre;
  final IconData icon;
  final Color color;

  const CanalInfo({
    required this.nombre,
    required this.icon,
    required this.color,
  });
}

class CanalHelper {
  CanalHelper._();

  static const Map<String, CanalInfo> _data = {
    "1": CanalInfo(
      nombre: 'WhatsApp',
      icon: Icons.message, // ✅ igual que web
      color: Color(0xFF25D366),
    ),
    "3": CanalInfo(
      nombre: 'TikTok',
      icon: Icons.music_note, // genérico (no hay icono oficial en Material)
      color: Color(0xFF010101),
    ),
    "4": CanalInfo(
      nombre: 'Instagram',
      icon: Icons.camera_alt_outlined, // ✅ similar al web
      color: Color(0xFFE1306C),
    ),
    "5": CanalInfo(
      nombre: 'Facebook',
      icon: Icons.facebook, // ✅ igual que web
      color: Color(0xFF1877F2),
    ),
    "6": CanalInfo(
      nombre: 'LinkedIn',
      icon: Icons.work_outline, // ✅ similar al web (maletín/in)
      color: Color(0xFF0A66C2),
    ),
    "7": CanalInfo(
      nombre: 'Web gs1',
      icon: Icons.language, // ✅ igual que web (globo)
      color: Color(0xFF607D8B),
    ),
    "8": CanalInfo(
      nombre: 'Instapage',
      icon: Icons.web_asset_outlined, // ✅ similar (página/sobre)
      color: Color(0xFFFF6B35),
    ),
    "9": CanalInfo(
      nombre: 'Boca a boca',
      icon: Icons.record_voice_over_outlined, // ✅ similar (voz/persona)
      color: Color(0xFF9C27B0),
    ),
    "10": CanalInfo(
      nombre: 'Migración Bitrix',
      icon: Icons.swap_horiz_rounded, // genérico (migración)
      color: Color(0xFF455A64),
    ),
    "11": CanalInfo(
      nombre: 'Referido',
      icon: Icons.people_outline, // ✅ similar (personas)
      color: Color(0xFF00897B),
    ),
    "12": CanalInfo(
      nombre: 'Manual',
      icon: Icons.edit_outlined, // ✅ similar (lápiz/cuaderno)
      color: Color(0xFF6D4C41),
    ),
  };

  static CanalInfo get(String id) =>
      _data[id] ??
      const CanalInfo(
        nombre: 'Desconocido',
        icon: Icons.help_outline,
        color: Color(0xFF9E9E9E),
      );

  static Widget icon(String id, {double size = AppSizing.iconNav}) {
    final info = get(id);
    return Icon(info.icon, color: info.color, size: size);
  }
}
