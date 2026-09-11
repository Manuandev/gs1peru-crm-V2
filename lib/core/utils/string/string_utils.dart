// lib/core/utils/string/string_utils.dart

import 'package:app_crm/core/index_core.dart';

extension StringExtensions on String {
  String get limpiarTelefono {
    final tienePlus = trimLeft().startsWith('+');
    final soloDigitos = replaceAll(RegExp(r'[^\d]'), '');
    return tienePlus ? '+$soloDigitos' : soloDigitos;
  }

  String get convertToHex {
    return codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Formato Título para nombres/apellidos de personas — pedido de negocio
  /// (2026-09-09): mostrar "Manuel Antonio Cardenas Valente", nunca
  /// "MANUEL ANTONIO CARDENAS VALENTE". Los datos en base están mezclados
  /// (unos en MAYÚSCULAS, otros ya en Título) — este helper los empareja al
  /// mostrarlos, sin tocar lo guardado (la app sigue guardando en MAYÚSCULAS).
  ///
  /// Primera letra de cada palabra en mayúscula, el resto en minúscula.
  /// Respeta guiones ("Jean-Paul") y baja a minúscula los conectores cortos
  /// del español/portugués salvo que sean la primera palabra ("María de la
  /// Cruz", no "María De La Cruz").
  String get aTitulo {
    const conectores = {
      'de', 'del', 'la', 'las', 'los', 'y', 'e', 'da', 'das', 'do', 'dos',
      'di', 'van', 'von',
    };
    final palabras = toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    for (var i = 0; i < palabras.length; i++) {
      final p = palabras[i];
      if (i != 0 && conectores.contains(p)) continue;
      palabras[i] = p
          .split('-')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join('-');
    }
    return palabras.join(' ');
  }

  // Nombre de archivo seguro para la API de WhatsApp — solo letras sin tilde,
  // números, guion, guion bajo y punto. Acentos/eñe/símbolos (incluyendo un
  // acento "suelto" mal codificado, ej. "NUTRICIO´N") hacen que Meta rechace
  // el envío del documento en silencio aunque el archivo ya esté guardado.
  String get sanitizarNombreArchivo {
    return replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
  }

  /// Quita los separadores del protocolo de los SP (¬ ¦ ¯ ¨) — para texto
  /// libre que viaja dentro del body (ej. el buscador de las listas
  /// paginadas): si el usuario pega uno, rompería el split del SP.
  String get sinSeparadoresSp => [
    AppConstants.sepRegistros,
    AppConstants.sepCampos,
    AppConstants.sepListas,
    AppConstants.sepComodin,
  ].fold(this, (texto, separador) => texto.replaceAll(separador, ''));
}

extension NullableStringExtensions on String? {
  String? get emailValidator {
    if (this == null || this!.trim().isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(this!.trim())) return 'Ingresa un email válido';
    return null;
  }
}
