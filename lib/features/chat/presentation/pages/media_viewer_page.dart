// lib\features\chat\presentation\pages\media_viewer_page.dart

import 'dart:io';
import 'package:gal/gal.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MediaViewerPage extends StatefulWidget {
  final String url;
  final String fileName;

  const MediaViewerPage({super.key, required this.url, required this.fileName});

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  final TransformationController _transformController =
      TransformationController();
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    if (_isDownloading) return;

    // ← Pedir permiso primero
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
      final isLocal = !widget.url.startsWith('http');

      if (isLocal) {
        // Imagen local — guardar directo en galería
        await Gal.putImage(widget.url);
        if (mounted) context.showSuccessSnack('Imagen guardada en galería');
        return;
      }

      // Imagen remota — descargar primero, luego a galería
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

      await Gal.putImage(savePath);
      if (mounted) context.showSuccessSnack('Imagen guardada en galería');
    } catch (_) {
      if (mounted) context.showErrorSnack('Error al guardar la imagen');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.fileName,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
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
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 5.0,

          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final isLocal = !widget.url.startsWith('http');

    if (isLocal) {
      return Image.file(
        File(widget.url),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _errorWidget(),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.contain,
      placeholder: (_, _) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      errorWidget: (_, _, _) => _errorWidget(),
    );
  }

  Widget _errorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_rounded, size: 64, color: Colors.white30),
        const SizedBox(height: 12),
        Text(
          'No se pudo cargar la imagen',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}
