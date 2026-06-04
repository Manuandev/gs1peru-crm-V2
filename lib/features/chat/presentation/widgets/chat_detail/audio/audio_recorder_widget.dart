// lib\features\chat\presentation\widgets\chat_detail\audio_recorder_widget.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class AudioRecorderWidget extends StatefulWidget {
  /// Llamado cuando el usuario termina de grabar y confirma el envío
  final void Function(String audioPath) onAudioReady;

  /// Llamado cuando el usuario cancela la grabación
  final VoidCallback onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onAudioReady,
    required this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _audioPath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      widget.onCancel();
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      _audioPath = path;
      _elapsed = Duration.zero;

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });

      if (mounted) setState(() => _isRecording = true);
    } catch (e) {
      widget.onCancel();
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorder.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _recorder.stop();

    // Borrar el archivo temporal
    if (_audioPath != null) {
      final file = File(_audioPath!);
      if (await file.exists()) await file.delete();
    }
    widget.onCancel();
  }

  void _sendRecording() {
    if (_audioPath != null) {
      widget.onAudioReady(_audioPath!);
    }
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.smPlus,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
      ),
      child: Row(
        children: [
          // ── Cancelar ──────────────────────────────────────────
          IconButton(
            icon: const Icon(AppIcons.delete),
            color: AppColors.errorLight,
            onPressed: _cancelRecording,
            tooltip: 'Cancelar',
          ),

          // ── Indicador / Timer ─────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRecording)
                  _PulsingDot(color: AppColors.errorLight),
                if (_isRecording) const SizedBox(width: AppSpacing.sm),
                Text(
                  _hasRecording
                      ? 'Listo para enviar'
                      : _formatElapsed(_elapsed),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _isRecording
                        ? AppColors.errorLight
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── Stop / Enviar ─────────────────────────────────────
          if (_isRecording)
            IconButton(
              icon: const Icon(AppIcons.stop),
              color: colorScheme.primary,
              onPressed: _stopRecording,
              tooltip: 'Detener',
            ),

          if (_hasRecording)
            IconButton(
              icon: const Icon(AppIcons.send),
              color: colorScheme.primary,
              onPressed: _sendRecording,
              tooltip: 'Enviar audio',
            ),
        ],
      ),
    );
  }
}

// ── Punto rojo pulsante ────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: AppColors.opacityEmptyText, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: AppSizing.splashDotSize,
        height: AppSizing.splashDotSize,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}