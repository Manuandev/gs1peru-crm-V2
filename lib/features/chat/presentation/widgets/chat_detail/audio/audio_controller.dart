// lib\features\chat\presentation\widgets\chat_detail\audio_controller.dart

import 'package:flutter/foundation.dart';

/// Controla qué audio está reproduciendo en este momento.
/// Cuando un AudioPlayerWidget empieza a reproducir, notifica su ID
/// y todos los demás se pausan.
class AudioController extends ChangeNotifier {
  String? _currentlyPlayingId;

  String? get currentlyPlayingId => _currentlyPlayingId;

  void play(String id) {
    if (_currentlyPlayingId != id) {
      _currentlyPlayingId = id;
      notifyListeners();
    }
  }

  void stop() {
    _currentlyPlayingId = null;
    notifyListeners();
  }
}