// lib\features\chat\presentation\widgets\chat_detail\chat_detail_scroll_controller.dart

import 'package:flutter/material.dart';

class ChatScrollController {
  final ScrollController controller = ScrollController();

  double _pixelsAntes = 0;
  double _maxExtentAntes = 0;

  void guardarPosicionAntes() {
    if (!controller.hasClients) return;
    _pixelsAntes = controller.position.pixels;
    _maxExtentAntes = controller.position.maxScrollExtent;
  }

  void restaurarPosicionDespuesDeCarga() {
    // triple frame: layout → medición → salto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.hasClients) return;
          final diff = controller.position.maxScrollExtent - _maxExtentAntes;
          if (diff > 0) controller.jumpTo(_pixelsAntes + diff);
        });
      });
    });
  }

  void irAlFondo({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;

      // ✅ Si no hay suficiente contenido para scrollear, no hacer nada
      final max = controller.position.maxScrollExtent;
      if (max <= 0) return;

      if (animated) {
        controller.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        controller.jumpTo(max);
      }
    });
  }

  void dispose() => controller.dispose();
}
