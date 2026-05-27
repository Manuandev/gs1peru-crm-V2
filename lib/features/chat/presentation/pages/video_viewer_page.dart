// lib/features/chat/presentation/pages/video_viewer_page.dart

import 'dart:io';
import 'package:app_crm/config/index_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoViewerPage extends StatefulWidget {
  final String url;
  final String fileName;

  const VideoViewerPage({super.key, required this.url, required this.fileName});

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  bool _isDownloading = false;
  double _downloadProgress = 0;
  bool _isInitializing = true;
  bool _hasError = false;

  bool get _isLocal => !widget.url.startsWith('http');

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = _isLocal
          ? VideoPlayerController.file(File(widget.url))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      if (mounted) setState(() => _isInitializing = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _download() async {
    if (_isDownloading) return;

    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
      final granted = await Gal.hasAccess();
      if (!granted) {
        if (mounted) {
          context.showErrorSnack('Permiso denegado para acceder a la galería');
        }
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      if (_isLocal) {
        await Gal.putVideo(widget.url);
        if (mounted) context.showSuccessSnack('Video guardado en galería');
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

      await Gal.putVideo(savePath);
      if (mounted) context.showSuccessSnack('Video guardado en galería');
    } catch (_) {
      if (mounted) context.showErrorSnack('Error al guardar el video');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // ignore: deprecated_member_use
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: Text(
          widget.fileName,
          style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
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
      ),
      body: Center(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar el video',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      );
    }

    return Chewie(controller: _chewieController!);
  }
}
