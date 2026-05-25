// lib/core/utils/elapsed_time_utils.dart

import 'package:flutter/material.dart';

class ElapsedTimeUtils {
  ElapsedTimeUtils._();

  /// "45m" o "2h 15m"
  static String format(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    if (minutes < 60) return '${minutes}m';
    final hours = elapsed.inHours;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  /// Color según urgencia
  static Color colorFromElapsed(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    if (minutes < 30) return const Color(0xFF2E7D32);   // verde
    if (minutes < 60) return const Color(0xFFF9A825);   // amarillo
    if (minutes < 180) return const Color(0xFFE65100);  // naranja
    return const Color(0xFFC62828);                      // rojo
  }
}