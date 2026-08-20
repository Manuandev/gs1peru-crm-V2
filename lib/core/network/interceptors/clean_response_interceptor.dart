// lib/core/network/interceptors/clean_response_interceptor.dart

import 'dart:convert';

import 'package:app_crm/index_dependencies.dart';

/// Deshace el JSON-string-literal que ASP.NET envuelve alrededor de las
/// respuestas de texto plano: el backend devuelve el resultado del SP como
/// string C#, y el formatter JSON de ASP.NET lo envuelve entre comillas y
/// escapa saltos de línea/comillas internas ('\r', '\n', '\"') como
/// cualquier string JSON — Dio no lo decodifica porque pedimos
/// `ResponseType.plain`.
///
/// Bug real (2026-08-20) — antes esto solo borraba comillas literales
/// (`replaceAll('"', '')`), lo que dejaba los escapes reales como texto
/// visible ("\n"/"\r" tal cual, ver chat/CLAUDE.md → plantillas) y además se
/// comía cualquier comilla real del contenido en vez de solo desescaparla.
/// `jsonDecode` deshace el escape completo (saltos, comillas, backslash,
/// unicode) en un solo paso, igual que si Dio hubiera parseado el JSON de
/// fábrica. Fallback al comportamiento anterior si el body no es un JSON
/// string válido (nunca debería pasar, pero evita romper algo si el backend
/// alguna vez manda texto plano sin envolver).
class CleanResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      final raw = response.data as String;
      try {
        final decoded = jsonDecode(raw);
        response.data = decoded is String ? decoded : raw;
      } on FormatException {
        response.data = raw.replaceAll('"', '').trim();
      }
    }
    handler.next(response);
  }
}