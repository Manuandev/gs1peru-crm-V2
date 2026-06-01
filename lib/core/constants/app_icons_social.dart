// lib/core/constants/app_icons_social.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

/// Íconos de redes sociales y canales usando FontAwesome.
/// Para usar: AppIconsSocial.canal(id) o AppIconsSocial.whatsapp
///
/// USO:
/// ```dart
/// FaIcon(AppIconsSocial.whatsapp, color: AppIconsSocial.colorCanal(1))
/// AppIconsSocial.widget(idCanal, size: 16) // widget listo
/// ```
class AppIconsSocial {
  AppIconsSocial._();

  // ============================================================
  // CANALES — íconos individuales
  // ============================================================
  static const FaIconData whatsapp = FontAwesomeIcons.whatsapp;
  static const FaIconData tiktok = FontAwesomeIcons.tiktok;
  static const FaIconData instagram = FontAwesomeIcons.instagram;
  static const FaIconData facebook = FontAwesomeIcons.facebook;
  static const FaIconData linkedin = FontAwesomeIcons.linkedin;
  static const FaIconData web = FontAwesomeIcons.globe; // Web gs1
  static const FaIconData instapage = FontAwesomeIcons.instagram;
  static const FaIconData bocaBoca = FontAwesomeIcons.microphone; // boca a boca
  static const FaIconData migracion =
      FontAwesomeIcons.arrowRightArrowLeft; // Migración
  static const FaIconData referido = FontAwesomeIcons.userGroup; // Referido
  static const FaIconData manual = FontAwesomeIcons.penToSquare; // Manual

  // ============================================================
  // ETAPAS — íconos individuales
  // ============================================================
  static const FaIconData etapaNuevo = FontAwesomeIcons.bell;
  static const FaIconData etapaEnDesarrollo = FontAwesomeIcons.chartLine;
  static const FaIconData etapaPropuesta = FontAwesomeIcons.chartBar;
  static const FaIconData etapaFicha = FontAwesomeIcons.idCard;
  static const FaIconData etapaCerrado = FontAwesomeIcons.eye;
  static const FaIconData etapaEvaluando = FontAwesomeIcons.magnifyingGlass;
  static const FaIconData etapaPrueba = FontAwesomeIcons.flask;
  static const FaIconData etapaPendiente = FontAwesomeIcons.hourglassHalf;
  static const FaIconData etapaSinRespuesta = FontAwesomeIcons.commentSlash;
  static const FaIconData etapaDesiste = FontAwesomeIcons.circleXmark;
  static const FaIconData etapaGanado = FontAwesomeIcons.trophy;
  static const FaIconData etapaPerdido = FontAwesomeIcons.faceSadTear;
  static const FaIconData etapaProximoPeriodo = FontAwesomeIcons.calendarDays;
  static const FaIconData etapaSinWhatsapp = FontAwesomeIcons.phoneSlash;
  static const FaIconData etapaFichaInscripcion =
      FontAwesomeIcons.clipboardList;

  // ============================================================
  // COLORES — canales
  // ============================================================
  static const Map<int, Color> _coloresCanal = {
    1: Color(0xFF25D366), // WhatsApp
    3: Color(0xFF010101), // TikTok
    4: Color(0xFFE1306C), // Instagram
    5: Color(0xFF1877F2), // Facebook
    6: Color(0xFF0A66C2), // LinkedIn
    7: Color(0xFF607D8B), // Web gs1
    8: Color(0xFFFF6B35), // Instapage
    9: Color(0xFF9C27B0), // Boca a boca
    10: Color(0xFF455A64), // Migración Bitrix
    11: Color(0xFF00897B), // Referido
    12: Color(0xFF6D4C41), // Manual
  };

  static const Map<String, Color> _coloresEstado = {
    "00": Color(0xFF2E7D32), // Nuevo
    "01": Color(0xFF1565C0), // En desarrollo
    "02": Color(0xFF6A1B9A), // Propuesta
    "03": Color(0xFF00695C), // Ficha
    "04": Color(0xFF37474F), // Cerrado
    "05": Color(0xFFE65100), // Evaluando
    "07": Color(0xFF558B2F), // Prueba
    "08": Color(0xFFF57F17), // Pendiente
    "09": Color(0xFFAD1457), // Sin respuesta
    "10": Color(0xFFB71C1C), // Desiste
    "11": Color(0xFF1B5E20), // Ganado
    "12": Color(0xFF880E4F), // Perdido
    "13": Color(0xFF004D40), // Próximo periodo
    "14": Color(0xFF4E342E), // Sin WhatsApp
    "15": Color(0xFF0D47A1), // Solicito ficha
  };

  static const Map<String, Color> _bgEstado = {
    "00": Color(0xFFE8F5E9),
    "01": Color(0xFFE3F2FD),
    "02": Color(0xFFF3E5F5),
    "03": Color(0xFFE0F2F1),
    "04": Color(0xFFECEFF1),
    "05": Color(0xFFFFF3E0),
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
  // HELPERS — canal
  // ============================================================
  static const Map<int, FaIconData> _iconosCanal = {
    1: whatsapp,
    3: tiktok,
    4: instagram,
    5: facebook,
    6: linkedin,
    7: web,
    8: instapage,
    9: bocaBoca,
    10: migracion,
    11: referido,
    12: manual,
  };

  static const Map<String, FaIconData> _iconosEstado = {
    "00": etapaNuevo,
    "01": etapaEnDesarrollo,
    "02": etapaPropuesta,
    "03": etapaFicha,
    "04": etapaCerrado,
    "05": etapaEvaluando,
    "07": etapaPrueba,
    "08": etapaPendiente,
    "09": etapaSinRespuesta,
    "10": etapaDesiste,
    "11": etapaGanado,
    "12": etapaPerdido,
    "13": etapaProximoPeriodo,
    "14": etapaSinWhatsapp,
    "15": etapaFichaInscripcion,
  };

  static Color colorCanal(int id) =>
      _coloresCanal[id] ?? const Color(0xFF9E9E9E);

  static Color colorEstado(String id) =>
      _coloresEstado[id] ?? const Color(0xFF9E9E9E);

  static Color bgEstado(String id) => _bgEstado[id] ?? const Color(0xFFF5F5F5);

  /// Ícono de canal listo para usar
  static Widget widgetCanal(int id, {double size = 14}) {
    final icon = FaIcon(
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
        child: icon,
      );
    }

    return icon;
  }

  /// Ícono de estado listo para usar
  static Widget widgetEstado(String id, {double size = 14}) => FaIcon(
    _iconosEstado[id] ?? FontAwesomeIcons.question,
    color: colorEstado(id),
    size: size,
  );

  /// Chip de estado listo para usar en cualquier widget
  static Widget chipEstado(String id, {TextStyle? textStyle, String? label}) {
    final color = colorEstado(id);
    final bg = bgEstado(id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label ?? '',
            style: (textStyle ?? const TextStyle()).copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
