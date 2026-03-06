// lib\features\chat\presentation\widgets\chat_detail\audio_player_widget.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final bool isEnviado;
  final AudioController audioController;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    required this.isEnviado,
    required this.audioController,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final String _id;

  @override
  void initState() {
    super.initState();
    _id = widget.audioPath;
    _player = AudioPlayer();
    _initPlayer();

    // Escuchar cuando otro audio empieza — pausar este
    widget.audioController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.audioController.currentlyPlayingId != _id && _isPlaying) {
      _player.pause();
    }
  }

  Future<void> _initPlayer() async {
    try {
      final isUrl = widget.audioPath.startsWith('http');
      if (isUrl) {
        await _player.setUrl(widget.audioPath);
      } else {
        await _player.setFilePath(widget.audioPath);
      }

      _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });

      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            widget.audioController.stop();
          }
        }
      });
    } catch (_) {
      // Audio no disponible aún (mensaje local pendiente de enviar)
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      widget.audioController.stop();
    } else {
      // Notifica a los demás que se pausan
      widget.audioController.play(_id);
      await _player.play();
    }
  }

  @override
  void dispose() {
    widget.audioController.removeListener(_onControllerChanged);
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.isEnviado
        ? colorScheme.onPrimary
        : colorScheme.primary;
    final trackColor = widget.isEnviado
        // ignore: deprecated_member_use
        ? colorScheme.onPrimary.withOpacity(0.3)
        // ignore: deprecated_member_use
        : colorScheme.primary.withOpacity(0.2);
    final activeTrackColor = widget.isEnviado
        // ignore: deprecated_member_use
        ? colorScheme.onPrimary.withOpacity(0.8)
        : colorScheme.primary;

    return SizedBox(
      width: 200,
      child: Row(
        children: [
          // ── Play/Pause ─────────────────────────────────────
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: iconColor.withOpacity(0.15),
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: iconColor,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Progress + duración ────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: activeTrackColor,
                    inactiveTrackColor: trackColor,
                    thumbColor: activeTrackColor,
                    overlayColor: trackColor,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds / _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (value) {
                      final pos = Duration(
                        milliseconds: (value * _duration.inMilliseconds)
                            .round(),
                      );
                      _player.seek(pos);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _formatDuration(
                      _isPlaying || _position > Duration.zero
                          ? _position
                          : _duration,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      // ignore: deprecated_member_use
                      color: iconColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
