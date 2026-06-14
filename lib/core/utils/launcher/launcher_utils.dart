// lib/core/utils/launcher/launcher_utils.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class LauncherUtils {
  LauncherUtils._();

  static Future<void> abrirTelefono(String telefono) async {
    final uri = Uri(scheme: 'tel', path: telefono.limpiarTelefono);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('No se pudo abrir el teléfono: $telefono');
    }
  }

  static Future<void> abrirCorreo(
    String correo, {
    String asunto = '',
    String cuerpo = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: correo,
      queryParameters: {
        if (asunto.isNotEmpty) 'subject': asunto,
        if (cuerpo.isNotEmpty) 'body': cuerpo,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('No se pudo abrir el correo: $correo');
    }
  }
}
