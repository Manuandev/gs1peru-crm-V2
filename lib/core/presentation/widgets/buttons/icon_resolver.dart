// lib/core/presentation/widgets/buttons/_icon_resolver.dart
//
// Helper interno — renderiza como FaIcon o Icon según el tipo en tiempo de ejecución.
// Acepta Object para soportar tanto IconData (Material) como FaIconData (FontAwesome).

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

/// Devuelve [FaIcon] si [data] es [FaIconData], [Icon] si es [IconData].
Widget resolveIcon(Object data, double size, Color color) {
  if (data is FaIconData) {
    return FaIcon(data, size: size, color: color);
  }
  return Icon(data as IconData, size: size, color: color);
}
