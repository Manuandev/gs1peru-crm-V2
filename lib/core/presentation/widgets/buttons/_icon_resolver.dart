// lib/core/presentation/widgets/buttons/_icon_resolver.dart
//
// Helper interno — renderiza IconData como FaIcon o Icon según su tipo.
// No exportar desde index_core.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

/// Devuelve [FaIcon] si [data] es [FaIconData], [Icon] en cualquier otro caso.
Widget resolveIcon(IconData data, double size, Color color) {
  if (data is FaIconData) {
    return FaIcon(data as FaIconData, size: size, color: color);
  }
  return Icon(data, size: size, color: color);
}
