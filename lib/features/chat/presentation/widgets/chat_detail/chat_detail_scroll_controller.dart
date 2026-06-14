// lib/features/chat/presentation/widgets/chat_detail/chat_detail_scroll_controller.dart
import 'package:flutter/material.dart';

class ChatScrollController {
  final ScrollController controller = ScrollController();

  void irAlFondo({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;

      if (animated) {
        controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        controller.jumpTo(0.0);
      }
    });
  }

  void dispose() => controller.dispose();
}
