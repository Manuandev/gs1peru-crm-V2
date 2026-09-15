// lib/features/chat/presentation/widgets/chat_detail/audio/audio_recorder_widget.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

/// Grabadora estilo WhatsApp: grabar → pausar → escuchar → continuar →
/// borrar o enviar. Nada se sube hasta tocar "Enviar" (y aun así el mensaje
/// pasa por la ventana de "Deshacer" del bloc).
///
/// Todo vive en la carpeta TEMPORAL del dispositivo: si el asesor borra la
/// grabación o sale de la pantalla, los archivos se eliminan. Se graba en AAC
/// por stream (se puede escuchar estando en pausa) y se empaqueta a `.m4a` con
/// [AacM4aMuxer] para la vista previa y para el envío.
class AudioRecorderWidget extends StatefulWidget {
  /// Llamado con la ruta del `.m4a` final cuando el usuario toca "Enviar"
  final void Function(String audioPath) onAudioReady;

  /// Llamado cuando el usuario borra la grabación
  final VoidCallback onCancel;

  /// Para que la vista previa pause a los demás audios del chat (y viceversa).
  /// Opcional: el formulario de plantillas no tiene otros audios — se usa uno local.
  final AudioController? audioController;

  const AudioRecorderWidget({
    super.key,
    required this.onAudioReady,
    required this.onCancel,
    this.audioController,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();

  AudioController? _audioControllerLocal;
  AudioController get _audioController =>
      widget.audioController ?? (_audioControllerLocal ??= AudioController());

  StreamSubscription<Uint8List>? _streamSub;
  IOSink? _sink;
  String? _rutaAac;

  bool _grabando = false;
  bool _pausado = false;
  bool _procesando = false; // armando la vista previa o el archivo final
  bool _enviado = false; // el .m4a final ya es del bloc — no borrarlo

  // Vista previa (.m4a) de lo grabado hasta la última pausa
  String? _rutaVistaPrevia;
  int _versionVistaPrevia = 0;

  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarGrabacion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSub?.cancel();
    _recorder.dispose();
    _sink?.close();
    _audioControllerLocal?.dispose();
    // Retroceder / salir sin enviar → no queda nada guardado
    _borrarTemporales(incluirFinal: false);
    super.dispose();
  }

  Future<void> _iniciarGrabacion() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      widget.onCancel();
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final ruta = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      _rutaAac = ruta;
      _sink = File(ruta).openWrite();

      final stream = await _recorder.startStream(
        const RecordConfig(encoder: AudioEncoder.aacLc),
      );
      _streamSub = stream.listen((bytes) => _sink?.add(bytes));

      _iniciarTimer();
      if (mounted) setState(() => _grabando = true);
    } catch (_) {
      widget.onCancel();
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _pausar() async {
    if (!_grabando || _procesando) return;
    _timer?.cancel();
    await _recorder.pause();
    await _sink?.flush();
    if (!mounted) return;
    setState(() {
      _grabando = false;
      _pausado = true;
    });
    await _armarVistaPrevia();
  }

  Future<void> _continuar() async {
    if (!_pausado || _procesando) return;
    _audioController.stop(); // pausa la vista previa si estaba sonando
    await _recorder.resume();
    _iniciarTimer();
    if (!mounted) return;
    setState(() {
      _pausado = false;
      _grabando = true;
    });
  }

  Future<void> _armarVistaPrevia() async {
    final origen = _rutaAac;
    if (origen == null) return;
    setState(() => _procesando = true);

    final anterior = _rutaVistaPrevia;
    final destino = '$origen.preview_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ok = await AacM4aMuxer.convertir(origen, destino);
    if (anterior != null) unawaited(_borrar(anterior));

    if (!mounted) return;
    setState(() {
      _procesando = false;
      _rutaVistaPrevia = ok ? destino : null;
      _versionVistaPrevia++;
    });
  }

  Future<void> _borrarGrabacion() async {
    _timer?.cancel();
    _audioController.stop();
    await _recorder.cancel();
    widget.onCancel(); // dispose() borra los temporales
  }

  Future<void> _enviar() async {
    final origen = _rutaAac;
    if (origen == null || _procesando) return;

    _timer?.cancel();
    _audioController.stop();
    setState(() => _procesando = true);

    await _recorder.stop();
    await _streamSub?.cancel();
    _streamSub = null;
    await _sink?.flush();
    await _sink?.close();
    _sink = null;

    final destino = '${origen.substring(0, origen.length - 4)}.m4a';
    final ok = await AacM4aMuxer.convertir(origen, destino);
    if (!mounted) return;

    if (!ok) {
      setState(() => _procesando = false);
      AppSnackBar.error(context, 'No se pudo procesar el audio. Vuelve a grabarlo.');
      widget.onCancel();
      return;
    }

    _enviado = true;
    widget.onAudioReady(destino);
  }

  void _borrarTemporales({required bool incluirFinal}) {
    final aac = _rutaAac;
    if (aac != null) {
      unawaited(_borrar(aac));
      if (incluirFinal || !_enviado) {
        unawaited(_borrar('${aac.substring(0, aac.length - 4)}.m4a'));
      }
    }
    final preview = _rutaVistaPrevia;
    if (preview != null) unawaited(_borrar(preview));
  }

  static Future<void> _borrar(String ruta) async {
    try {
      final archivo = File(ruta);
      if (await archivo.exists()) await archivo.delete();
    } catch (_) {
      // Best-effort: es un temporal
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
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
      ),
      child: Row(
        children: [
          // ── Borrar ────────────────────────────────────────────
          IconButton(
            icon: const Icon(AppIcons.delete),
            color: AppColors.errorLight,
            onPressed: _procesando && !_pausado ? null : _borrarGrabacion,
            tooltip: 'Borrar',
          ),

          // ── Centro: timer grabando / vista previa en pausa ────
          Expanded(child: _buildCentro(colorScheme)),

          // ── Pausar / Continuar ────────────────────────────────
          if (_grabando)
            IconButton(
              icon: const Icon(AppIcons.pause),
              color: AppColors.errorLight,
              onPressed: _procesando ? null : _pausar,
              tooltip: 'Pausar',
            )
          else if (_pausado)
            IconButton(
              icon: const Icon(AppIcons.mic),
              color: AppColors.errorLight,
              onPressed: _procesando ? null : _continuar,
              tooltip: 'Continuar grabando',
            ),

          // ── Enviar ────────────────────────────────────────────
          IconButton(
            icon: const Icon(AppIcons.send),
            color: colorScheme.primary,
            onPressed: (_grabando || _pausado) && !_procesando ? _enviar : null,
            tooltip: 'Enviar audio',
          ),
        ],
      ),
    );
  }

  Widget _buildCentro(ColorScheme colorScheme) {
    if (_pausado) {
      if (_procesando) {
        return const Center(
          child: SizedBox(
            width: AppSizing.spinnerSizeSm,
            height: AppSizing.spinnerSizeSm,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeSmall,
            ),
          ),
        );
      }
      final preview = _rutaVistaPrevia;
      if (preview != null) {
        return AudioPlayerWidget(
          // Nueva instancia en cada pausa — el archivo cambió
          key: ValueKey('preview_$_versionVistaPrevia'),
          audioPath: preview,
          isEnviado: false,
          audioController: _audioController,
        );
      }
      return Center(
        child: Text(
          _formatElapsed(_elapsed),
          style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_grabando) ...[
          _PulsingDot(color: AppColors.errorLight),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          _formatElapsed(_elapsed),
          style: AppTextStyles.labelLarge.copyWith(
            color: _grabando ? AppColors.errorLight : colorScheme.onSurface,
          ),
        ),
      ],
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
