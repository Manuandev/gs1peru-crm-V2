// lib\core\utils\launcher\launcher_utils.dart

import 'package:url_launcher/url_launcher.dart';

Future<void> abrirTelefono(String telefono) async {
  final uri = Uri(scheme: 'tel', path: telefono);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw Exception('No se pudo abrir el teléfono: $telefono');
  }
}

Future<void> abrirCorreo(
  String correoCliente, {
  String asunto = '',
  String cuerpo = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: correoCliente,
    queryParameters: {
      if (asunto.isNotEmpty) 'subject': asunto,
      if (cuerpo.isNotEmpty) 'body': cuerpo,
    },
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw Exception('No se pudo abrir el correo para: $correoCliente');
  }
}
