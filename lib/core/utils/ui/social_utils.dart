// lib/core/utils/ui/social_utils.dart
//
// Utilidades de colores y widgets para canales de origen y etapas CRM.
// Los íconos viven en AppIcons — aquí solo colores, mapas y helpers visuales.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/constants/app_icons.dart';

class AppSocialUtils {
  AppSocialUtils._();

  // ============================================================
  // COLORES — canales
  // ============================================================
  static const Map<int, Color> _coloresCanal = {
    1: Color(0xFF25D366), // WhatsApp
    3: Color(0xFF010101), // TikTok
    4: Color(0xFFE1306C), // Instagram
    5: Color(0xFF1877F2), // Facebook
    6: Color(0xFF0A66C2), // LinkedIn
    7: Color(0xFF607D8B), // Web GS1
    8: Color(0xFFFF6B35), // Instapage
    9: Color(0xFF9C27B0), // Boca a boca
    10: Color(0xFF455A64), // Migración
    11: Color(0xFF00897B), // Referido
    12: Color(0xFF6D4C41), // Manual
  };

  // ============================================================
  // COLORES — estados (texto y fondo)
  // ============================================================
  static const Map<String, Color> _coloresEstado = {
    "00": Color(0xFF2E7D32),
    "01": Color(0xFFE65100),
    "02": Color(0xFF1565C0),
    "03": Color(0xFF00695C),
    "04": Color(0xFF7B1FA2),
    "05": Color(0xFFF57C00),
    "07": Color(0xFF558B2F),
    "08": Color(0xFFF57F17),
    "09": Color(0xFFAD1457),
    "10": Color(0xFFB71C1C),
    "11": Color(0xFF1B5E20),
    "12": Color(0xFF880E4F),
    "13": Color(0xFF004D40),
    "14": Color(0xFF4E342E),
    "15": Color(0xFF0D47A1),
  };

  static const Map<String, Color> _bgEstado = {
    "00": Color(0xFFE8F5E9),
    "01": Color(0xFFFFF3E0),
    "02": Color(0xFFE3F2FD),
    "03": Color(0xFFE0F2F1),
    "04": Color(0xFFF3E5F5),
    "05": Color(0xFFFFF8E1),
    "07": Color(0xFFF1F8E9),
    "08": Color(0xFFFFFDE7),
    "09": Color(0xFFFCE4EC),
    "10": Color(0xFFFFEBEE),
    "11": Color(0xFFE8F5E9),
    "12": Color(0xFFFCE4EC),
    "13": Color(0xFFE0F2F1),
    "14": Color(0xFFEFEBE9),
    "15": Color(0xFFE3F2FD),
  };

  // ============================================================
  // MAPAS — ícono por canal/estado
  // ============================================================
  static const Map<int, FaIconData> _iconosCanal = {
    1: AppIcons.whatsapp,
    3: AppIcons.tiktok,
    4: AppIcons.instagram,
    5: AppIcons.facebook,
    6: AppIcons.linkedin,
    7: AppIcons.web,
    8: AppIcons.instapage,
    9: AppIcons.bocaBoca,
    10: AppIcons.migracion,
    11: AppIcons.referido,
    12: AppIcons.manual,
  };

  static const Map<String, FaIconData> _iconosEstado = {
    "00": AppIcons.etapaNuevo,
    "01": AppIcons.etapaEnDesarrollo,
    "02": AppIcons.etapaPropuesta,
    "03": AppIcons.etapaFicha,
    "04": AppIcons.etapaCerrado,
    "05": AppIcons.etapaEvaluando,
    "07": AppIcons.etapaPrueba,
    "08": AppIcons.etapaPendiente,
    "09": AppIcons.etapaSinRespuesta,
    "10": AppIcons.etapaDesiste,
    "11": AppIcons.etapaGanado,
    "12": AppIcons.etapaPerdido,
    "13": AppIcons.etapaProximoPeriodo,
    "14": AppIcons.etapaSinWhatsapp,
    "15": AppIcons.etapaFichaInscripcion,
  };

  // ============================================================
  // ACCESORES DE COLOR
  // ============================================================
  static Color colorCanal(int id) =>
      _coloresCanal[id] ?? const Color(0xFF9E9E9E);

  static Color colorEstado(String id) =>
      _coloresEstado[id] ?? const Color(0xFF9E9E9E);

  static Color bgEstado(String id) =>
      _bgEstado[id] ?? const Color(0xFFF5F5F5);

  // ============================================================
  // WIDGETS LISTOS
  // ============================================================

  /// FaIcon del canal con color de marca. Instagram/Instapage llevan gradiente.
  static Widget widgetCanal(int id, {double size = 14}) {
    final icono = FaIcon(
      _iconosCanal[id] ?? FontAwesomeIcons.question,
      color: id == 4 || id == 8 ? Colors.white : colorCanal(id),
      size: size,
    );

    if (id == 4 || id == 8) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => const LinearGradient(
          colors: [
            Color(0xFFfeda75),
            Color(0xFFfa7e1e),
            Color(0xFFd62976),
            Color(0xFF962fbf),
            Color(0xFF4f5bd5),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ).createShader(bounds),
        child: icono,
      );
    }

    return icono;
  }

  /// FaIcon del estado con color de etapa.
  static Widget widgetEstado(String id, {double size = 14}) => FaIcon(
        _iconosEstado[id] ?? FontAwesomeIcons.question,
        color: colorEstado(id),
        size: size,
      );

  /// Chip compacto con etiqueta y color de etapa.
  static Widget chipEstado(
    String id, {
    TextStyle? textStyle,
    String? label,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    final color = colorEstado(id);
    final bg = bgEstado(id);
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label ?? '',
        style: (textStyle ?? const TextStyle()).copyWith(
          color: color,
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
