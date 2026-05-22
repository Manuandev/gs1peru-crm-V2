// lib/features/chat/presentation/widgets/chat_detail/message_parser.dart
//
// ✅ MOVIDO desde message_bubble.dart
//    Lógica de parseo de texto puro — no tiene nada que hacer en un widget.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parsea un mensaje con formato WhatsApp:
/// *bold*, _italic_, ~tachado~, `mono`, URLs clicables y saltos de línea.
List<InlineSpan> parseMensaje(String mensaje, Color textColor) {
  // Normaliza saltos de línea
  final normalized = mensaje
      .replaceAll(r'\\n', '\n')
      .replaceAll(r'\n', '\n');

  final tokens = _splitByUrls(normalized);

  final List<InlineSpan> spans = [];
  for (final token in tokens) {
    if (_isUrl(token)) {
      spans.add(_urlSpan(token));
    } else {
      spans.addAll(_parseFormatted(token, textColor));
    }
  }
  return spans;
}

// ── URL helpers ───────────────────────────────────────────────────────────────

final _urlRegex = RegExp(
  r'(https?://[^\s\\]+|www\.[^\s\\]+)',
  caseSensitive: false,
);

List<String> _splitByUrls(String text) {
  final List<String> tokens = [];
  int last = 0;
  for (final match in _urlRegex.allMatches(text)) {
    if (match.start > last) tokens.add(text.substring(last, match.start));
    tokens.add(match.group(0)!);
    last = match.end;
  }
  if (last < text.length) tokens.add(text.substring(last));
  return tokens;
}

bool _isUrl(String token) => _urlRegex.hasMatch(token);

InlineSpan _urlSpan(String url) {
  return TextSpan(
    text: url,
    style: TextStyle(
      color: Colors.lightBlue.shade300,
      fontSize: 14,
      height: 1.4,
      decoration: TextDecoration.underline,
      decorationColor: Colors.lightBlue.shade300,
    ),
    recognizer: TapGestureRecognizer()
      ..onTap = () async {
        final fullUrl = url.startsWith('http') ? url : 'https://$url';
        final uri = Uri.tryParse(fullUrl);
        if (uri == null) return;
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      },
  );
}

// ── Formato WhatsApp: *bold* _italic_ ~strike~ `mono` ────────────────────────

final _formatRegex = RegExp(
  r'\*([^*\n]+)\*|_([^_\n]+)_|~([^~\n]+)~|`([^`\n]+)`',
);

List<InlineSpan> _parseFormatted(String text, Color textColor) {
  final List<InlineSpan> spans = [];
  int last = 0;

  final base = TextStyle(color: textColor, fontSize: 14, height: 1.4);

  for (final match in _formatRegex.allMatches(text)) {
    if (match.start > last) {
      spans.add(TextSpan(text: text.substring(last, match.start), style: base));
    }

    if (match.group(1) != null) {
      spans.add(TextSpan(
        text: match.group(1),
        style: base.copyWith(fontWeight: FontWeight.bold),
      ));
    } else if (match.group(2) != null) {
      spans.add(TextSpan(
        text: match.group(2),
        style: base.copyWith(fontStyle: FontStyle.italic),
      ));
    } else if (match.group(3) != null) {
      spans.add(TextSpan(
        text: match.group(3),
        style: base.copyWith(decoration: TextDecoration.lineThrough),
      ));
    } else if (match.group(4) != null) {
      spans.add(TextSpan(
        text: match.group(4),
        style: base.copyWith(
          fontFamily: 'monospace',
          // ignore: deprecated_member_use
          backgroundColor: textColor.withOpacity(0.1),
          letterSpacing: 0.5,
        ),
      ));
    }

    last = match.end;
  }

  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }

  return spans;
}