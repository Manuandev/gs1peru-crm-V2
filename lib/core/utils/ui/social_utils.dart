// lib/core/utils/ui/social_utils.dart
//
// Utilidades de colores y widgets para canales de origen y etapas CRM.
// Los íconos viven en AppIcons — aquí solo colores, mapas y helpers visuales.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class AppSocialUtils {
  AppSocialUtils._();

  // ============================================================
  // MAPA DE PUENTE — id numérico → iconoApp
  // Refleja los IDs reales de CRM.T_CANAL.
  // Solo actualizar aquí si se agregan canales nuevos en BD.
  // ============================================================
  static const Map<int, String> _idAIconoApp = {
    1: 'facebook',
    2: 'instagram',
    3: 'tiktok',
    4: 'web',
    5: 'whatsapp',
    6: 'mailing',
    7: 'sms',
    8: 'recomendacion',
    9: 'llamada',
    10: 'visita',
    11: 'telegram',
    12: 'manual',
  };

  static String? iconoAppById(int id) => _idAIconoApp[id];

  // ============================================================
  // COLORES — canales (keyed por ICONO_APP de la BD)
  // ============================================================
  static const Map<String, Color> _coloresCanal = {
    'facebook': Color(0xFF1877F2),
    'instagram': Color(0xFFE1306C),
    'tiktok': Color(0xFF010101),
    'web': Color(0xFF607D8B),
    'whatsapp': Color(0xFF25D366),
    'mailing': Color(0xFF0A66C2),
    'sms': Color(0xFF455A64),
    'recomendacion': Color(0xFF9C27B0),
    'llamada': Color(0xFF00897B),
    'visita': Color(0xFF6D4C41),
    'telegram': Color(0xFF2CA5E0),
    'manual': Color(0xFF6D4C41),
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
  static const Map<String, FaIconData> _iconosCanal = {
    'facebook': AppIcons.facebook,
    'instagram': AppIcons.instagram,
    'tiktok': AppIcons.tiktok,
    'web': AppIcons.web,
    'whatsapp': AppIcons.whatsapp,
    'mailing': AppIcons.linkedin, // Todo: agregar AppIcons.mailing
    'sms': AppIcons.manual, // Todo: agregar AppIcons.sms
    'recomendacion': AppIcons.bocaBoca,
    'llamada': AppIcons.manual, // Todo: agregar AppIcons.llamada
    'visita': AppIcons.migracion, // Todo: agregar AppIcons.visita
    'telegram': AppIcons.referido, // Todo: agregar AppIcons.telegram
    'manual': AppIcons.manual,
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
  static Color colorCanal(String? iconoApp) =>
      _coloresCanal[iconoApp ?? ''] ?? const Color(0xFF9E9E9E);

  static Color colorCanalById(int id) => colorCanal(iconoAppById(id));

  static Widget widgetCanalById(int id, {double size = 14}) =>
      widgetCanal(iconoAppById(id), size: size);

  /// Resuelve el ícono usando la lista real de canales del catálogo (CatalogsBloc).
  /// Usa el campo iconoApp que viene de la BD — evita depender del mapa hardcodeado.
  static Widget widgetCanalFromList(
    List<CanalItem> canales,
    int id, {
    double size = 14,
  }) {
    final iconoApp = canales.where((c) => c.id == id).firstOrNull?.iconoApp;
    return widgetCanal(iconoApp, size: size);
  }

  static Color colorEstado(String id) =>
      _coloresEstado[id] ?? const Color(0xFF9E9E9E);

  static Color bgEstado(String id) => _bgEstado[id] ?? const Color(0xFFF5F5F5);

  /// Ícono crudo del estado (sin color ni widget armado) — para componer un
  /// [FaIcon] propio cuando no aplica [widgetEstado] (ej. prefixIcon de un
  /// combo, que usa el tamaño/estilo de los demás campos del formulario).
  static FaIconData iconoEstado(String id) =>
      _iconosEstado[id] ?? FontAwesomeIcons.question;

  // ============================================================
  // MAPA DE PUENTE — canal expo (CanalExpoItem, dbo.EDU_CANAL_EXPO)
  // "¿Cómo se enteró del evento?" — catálogo aparte del canal de origen
  // del lead (T_CANAL de arriba), con sus propios ids.
  // El id 4 (LOGÍSTICA) ya no lo devuelve el SP como opción activa, pero
  // se deja mapeado para solicitudes viejas que ya lo tengan guardado.
  // ============================================================
  static const Map<int, String> _idAIconoAppCanalExpo = {
    1: 'facebook',
    2: 'linkedin',
    3: 'instagram',
    4: 'logistica',
    5: 'logistica360',
    6: 'otros',
  };

  static String? iconoAppCanalExpoById(int id) => _idAIconoAppCanalExpo[id];

  static const Map<String, Color> _coloresCanalExpo = {
    'facebook': Color(0xFF1877F2),
    'linkedin': Color(0xFF0A66C2),
    'instagram': Color(0xFFE1306C),
    'logistica': Color(0xFF6D4C41),
    'logistica360': Color(0xFF6D4C41),
    'otros': Color(0xFF9E9E9E),
  };

  static const Map<String, FaIconData> _iconosCanalExpo = {
    'facebook': AppIcons.facebook,
    'linkedin': AppIcons.linkedin,
    'instagram': AppIcons.instagram,
    'logistica': AppIcons.canalExpoLogistica,
    'logistica360': AppIcons.canalExpoLogistica,
    'otros': AppIcons.canalExpoOtros,
  };

  static Color colorCanalExpo(String? iconoApp) =>
      _coloresCanalExpo[iconoApp ?? ''] ?? const Color(0xFF9E9E9E);

  static Color colorCanalExpoById(int id) =>
      colorCanalExpo(iconoAppCanalExpoById(id));

  static Widget widgetCanalExpoById(int id, {double size = 14}) =>
      widgetCanalExpo(iconoAppCanalExpoById(id), size: size);

  /// FaIcon del canal expo con color propio. Instagram lleva gradiente,
  /// igual que [widgetCanal].
  static Widget widgetCanalExpo(String? iconoApp, {double size = 14}) {
    final faSize = AppSizing.faSize(size);
    final esInstagram = iconoApp == 'instagram';

    final icono = FaIcon(
      _iconosCanalExpo[iconoApp ?? ''] ?? FontAwesomeIcons.question,
      color: esInstagram ? Colors.white : colorCanalExpo(iconoApp),
      size: faSize,
    );

    Widget resultado = icono;
    if (esInstagram) {
      resultado = ShaderMask(
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

    return SizedBox(
      width: faSize,
      height: faSize,
      child: Center(child: resultado),
    );
  }

  // ============================================================
  // WIDGETS LISTOS
  // ============================================================

  /// FaIcon del canal con color de marca. Instagram lleva gradiente.
  /// El tamaño se ajusta con [AppSizing.faSize] para que FA quede
  /// visualmente igual a un Material Icon del mismo valor de [size].
  static Widget widgetCanal(String? iconoApp, {double size = 14}) {
    final faSize = AppSizing.faSize(size);
    final esInstagram = iconoApp == 'instagram';

    final icono = FaIcon(
      _iconosCanal[iconoApp ?? ''] ?? FontAwesomeIcons.question,
      color: esInstagram ? Colors.white : colorCanal(iconoApp),
      size: faSize,
    );

    Widget resultado = icono;
    if (esInstagram) {
      resultado = ShaderMask(
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

    // SizedBox + Center replica el comportamiento de Icon nativo:
    // define tamaño explícito y centra el ícono dentro del slot prefixIcon.
    return SizedBox(
      width: faSize,
      height: faSize,
      child: Center(child: resultado),
    );
  }

  /// FaIcon del estado con color de etapa.
  static Widget widgetEstado(String id, {double size = 14}) {
    final faSize = AppSizing.faSize(size);
    return SizedBox(
      width: faSize,
      height: faSize,
      child: Center(
        child: FaIcon(
          _iconosEstado[id] ?? FontAwesomeIcons.question,
          color: colorEstado(id),
          size: faSize,
        ),
      ),
    );
  }

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
