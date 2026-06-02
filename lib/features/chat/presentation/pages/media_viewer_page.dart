// lib/features/chat/presentation/pages/media_viewer_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class MediaViewerPage extends StatefulWidget {
  final String url;
  final String fileName;

  /// Nombre del usuario que envió el archivo (ej: "Carlos Pérez")
  final String? senderName;

  /// Fecha de envío (ej: "May 27 2026 10:46AM")
  final String? sentAt;

  /// Si no se pasa [mediaType], se infiere por extensión del [fileName]
  final MediaType? mediaType;

  const MediaViewerPage({
    super.key,
    required this.url,
    required this.fileName,
    this.senderName,
    this.sentAt,
    this.mediaType,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage>
    with SingleTickerProviderStateMixin {
  // ─── Imagen: zoom & pan ───────────────────────────────────────────────────
  final TransformationController _transformController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  // ─── Video ────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoInitializing = true;
  bool _videoError = false;

  // ─── Descarga ─────────────────────────────────────────────────────────────
  bool _isDownloading = false;
  double _downloadProgress = 0;

  // ─── Info ─────────────────────────────────────────────────────────────────
  bool _showInfo = true; // muestra header/footer breves, se oculta al tocar

  // ─── Helpers ──────────────────────────────────────────────────────────────
  bool get _isLocal => !widget.url.startsWith('http');

  MediaType get _resolvedType {
    if (widget.mediaType != null) return widget.mediaType!;
    final ext = widget.fileName.split('.').last.toLowerCase();
    const videoExts = {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'};
    return videoExts.contains(ext) ? MediaType.video : MediaType.image;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_animation != null) {
            _transformController.value = _animation!.value;
          }
        });

    if (_resolvedType == MediaType.video) _initVideo();
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // ─── Video init ───────────────────────────────────────────────────────────
  Future<void> _initVideo() async {
    try {
      _videoController = _isLocal
          ? VideoPlayerController.file(File(widget.url))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      if (mounted) setState(() => _videoInitializing = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _videoInitializing = false;
          _videoError = true;
        });
      }
    }
  }

  // ─── Zoom (doble tap estilo WhatsApp) ────────────────────────────────────
  void _onDoubleTap(TapDownDetails details) {
    final matrix = _transformController.value;
    const zoomLevel = 3.0;

    if (matrix.isIdentity()) {
      // Zoom IN centrado en el toque
      final pos = details.localPosition;
      final zoomed = Matrix4.identity()
        // ignore: deprecated_member_use
        ..translate(-pos.dx * (zoomLevel - 1), -pos.dy * (zoomLevel - 1))
        // ignore: deprecated_member_use
        ..scale(zoomLevel);

      _animation = Matrix4Tween(begin: matrix, end: zoomed).animate(
        CurveTween(curve: Curves.easeOutCubic).animate(_animController),
      );
    } else {
      // Zoom OUT → identidad
      _animation = Matrix4Tween(begin: matrix, end: Matrix4.identity()).animate(
        CurveTween(curve: Curves.easeOutCubic).animate(_animController),
      );
    }
    _animController.forward(from: 0);
  }

  // ─── Descarga ─────────────────────────────────────────────────────────────
  Future<void> _download() async {
    if (_isDownloading) return;

    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
      if (!await Gal.hasAccess()) {
        if (mounted) {
          AppSnackBar.error(
            context,
            'Permiso denegado para acceder a la galería',
          );
        }
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final isVideo = _resolvedType == MediaType.video;

      if (_isLocal) {
        if (isVideo) {
          await Gal.putVideo(widget.url);
        } else {
          await Gal.putImage(widget.url);
        }
        if (mounted) {
          AppSnackBar.success(
            context,
            '${isVideo ? "Video" : "Imagen"} guardado en galería',
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${widget.fileName}';

      await Dio().download(
        widget.url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (isVideo) {
        await Gal.putVideo(savePath);
      } else {
        await Gal.putImage(savePath);
      }

      if (mounted) {
        AppSnackBar.success(
          context,
          '${isVideo ? "Video" : "Imagen"} guardado en galería',
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Error al guardar el archivo');
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BasePage(
      bodyPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      drawerSide: DrawerSide.none,
      // 👇 botón back
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],
      titleWidget: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.senderName != null && widget.senderName!.isNotEmpty)
              Text(
                widget.senderName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              widget.sentAt?.formatWhatsAppMultimedia() ?? '',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      appBarTrailingButtons: [
        if (_isDownloading)
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Descargar',
            onPressed: _download,
          ),
      ],

      body: Stack(
        children: [
          // ── Contenido principal ──────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _showInfo = !_showInfo),
            child: _resolvedType == MediaType.image
                ? _buildImageViewer()
                : _buildVideoViewer(),
          ),
        ],
      ),
    );
  }

  // ─── Image viewer ─────────────────────────────────────────────────────────
  Widget _buildImageViewer() {
    return Dismissible(
      key: const Key('media_viewer_dismissible'),
      direction: DismissDirection.vertical,
      onDismissed: (_) => Navigator.of(context).pop(),
      child: SizedBox.expand(
        child: GestureDetector(
          onDoubleTapDown: _onDoubleTap,
          onDoubleTap: () {}, // necesario para que onDoubleTapDown se dispare
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.5,
            maxScale: 6.0,
            // sin boundaryMargin → libre como WhatsApp
            boundaryMargin: EdgeInsets.zero,
            clipBehavior: Clip.none,
            child: Center(child: _buildImageContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isLocal) {
      return Image.file(
        File(widget.url),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imageErrorWidget(),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      errorWidget: (_, __, ___) => _imageErrorWidget(),
    );
  }

  Widget _imageErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_rounded, size: 64, color: Colors.white30),
        const SizedBox(height: 12),
        const Text(
          'No se pudo cargar la imagen',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  // ─── Video viewer ─────────────────────────────────────────────────────────
  Widget _buildVideoViewer() {
    if (_videoInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_videoError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudo cargar el video',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      );
    }

    return Chewie(controller: _chewieController!);
  }
}
