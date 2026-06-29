// lib/features/chat/presentation/widgets/chat_detail/chat_onda_banner.dart
//
// Fondo con ola convexa azul detrás del banner de IA.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatOndaBanner extends StatelessWidget {
  final Chat? chat;
  const ChatOndaBanner({super.key, this.chat});

  @override
  Widget build(BuildContext context) {
    if (chat == null || !chat!.isDerivadoIA) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _OndaPainter(colorScheme.primary),
      child: ChatIaBanner(chat: chat!),
    );
  }
}

// Pinta azul de arriba hasta la mitad del card, con ola convexa hacia abajo.
class _OndaPainter extends CustomPainter {
  final Color color;
  const _OndaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const ola = AppSpacing.xxxl;
    final mitad = size.height / 2;
    final path = Path()
      ..lineTo(0, mitad)
      ..quadraticBezierTo(size.width / 2, mitad + ola, size.width, mitad)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OndaPainter old) => old.color != color;
}
