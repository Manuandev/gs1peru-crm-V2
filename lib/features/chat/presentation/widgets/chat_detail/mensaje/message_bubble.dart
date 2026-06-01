// lib\features\chat\presentation\widgets\chat_detail\message_bubble.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MessageBubble — burbuja principal
// ─────────────────────────────────────────────────────────────────────────────

bool _isLocalFileHelper(ChatMessage msg) {
  if (msg.tipo == 'text' || msg.tipo == 'template' || msg.tipo == 'button') {
    return false;
  }
  final m = msg.mensaje;
  return m.isNotEmpty &&
      (m.startsWith('/') || m.startsWith('file://') || m.contains(r':\'));
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AudioController audioController;
  final int idLead;
  final String nombre;

  const MessageBubble({
    super.key,
    required this.message,
    required this.audioController,
    required this.idLead,
    required this.nombre,
  });

  bool get _isImageMsg => MessageUrlHelper.isImage(message);
  bool get _isVideoMsg => MessageUrlHelper.isVideo(message);
  bool get _isMediaMsg => _isImageMsg || _isVideoMsg;
  bool get _isLocalFile => _isLocalFileHelper(message);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnviado = message.isEnviado;

    final bubbleColor = isEnviado
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    final textColor = isEnviado ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isEnviado ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: isEnviado ? 48 : 0,
            right: isEnviado ? 0 : 48,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: _bubbleRadius(isEnviado),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            // Estilo WhatsApp: un ligero padding (2px) para fotos/videos, o 0 para texto.
            padding: _isMediaMsg ? const EdgeInsets.all(2) : EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: _isMediaMsg
                  ? _innerBubbleRadius(isEnviado)
                  : _bubbleRadius(isEnviado),
              child: _isMediaMsg
                  ? Stack(
                      children: [
                        _buildContent(context, textColor),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _BubbleTimeRow(
                            fecha: message.fecha,
                            estado: message.estado,
                            isEnviado: isEnviado,
                            isOverImage: true,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildContent(context, textColor),
                        _BubbleTimeRow(
                          fecha: message.fecha,
                          estado: message.estado,
                          isEnviado: isEnviado,
                          isOverImage: false,
                          textColor: textColor,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _bubbleRadius(bool isEnviado) {
    return BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isEnviado ? 16 : 4),
      bottomRight: Radius.circular(isEnviado ? 4 : 16),
    );
  }

  BorderRadius _innerBubbleRadius(bool isEnviado) {
    // Si la burbuja externa tiene 16px de radio y 2px de padding, la interna debería tener ~14px.
    return BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isEnviado ? 14 : 3),
      bottomRight: Radius.circular(isEnviado ? 3 : 14),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    switch (message.tipo) {
      case 'image':
        return _ImageContent(message: message, idLead: idLead, nombre: nombre);

      case 'audio':
        final path = _isLocalFile
            ? message.mensaje
            : MessageUrlHelper.buildFileUrl(message, idLead);
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: AudioPlayerWidget(
            audioPath: path,
            isEnviado: message.isEnviado,
            audioController: audioController,
          ),
        );

      case 'video':
        return _VideoContent(message: message, idLead: idLead, nombre: nombre);

      case 'document':
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: _DocumentContent(
            message: message,
            idLead: idLead,
            textColor: textColor,
          ),
        );

      case 'template':
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: _TemplateContent(
            message: message,
            idLead: idLead,
            textColor: textColor,
            audioController: audioController,
            nombre: nombre,
          ),
        );

      // text, button y cualquier otro tipo → texto plano
      case 'text':
      case 'button':
      default:
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),

          // child: Text(
          //   message.mensaje,
          //   style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
          // ),
          child: RichText(
            text: TextSpan(children: parseMensaje(message.mensaje, textColor)),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BubbleTimeRow — hora y estado al pie de la burbuja
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleTimeRow extends StatelessWidget {
  final String fecha;
  final String estado;
  final bool isEnviado;
  final bool isOverImage;
  final Color textColor;

  const _BubbleTimeRow({
    required this.fecha,
    required this.estado,
    required this.isEnviado,
    required this.isOverImage,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final timeColor = isOverImage
        ? Colors.white
        // ignore: deprecated_member_use
        : textColor.withOpacity(0.65);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fecha.formatDate(AppDateFormat.hourMinute),
          style: TextStyle(fontSize: 10, color: timeColor),
        ),
        if (isEnviado) ...[
          const SizedBox(width: 4),
          MessageStatusIcon(
            estado: estado,
            color: isOverImage ? Colors.white : textColor,
          ),
        ],
      ],
    );

    if (isOverImage) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(10),
          ),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ImageContent — imagen inline con visor
// ─────────────────────────────────────────────────────────────────────────────

class _ImageContent extends StatelessWidget {
  final ChatMessage message;
  final int idLead;
  final String nombre;

  const _ImageContent({
    required this.message,
    required this.idLead,
    required this.nombre,
  });

  bool get _isLocal => _isLocalFileHelper(message);

  void _openViewer(BuildContext context, String urlOrPath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MediaViewerPage(
          url: urlOrPath,
          fileName: '${message.nomArchivo}${message.extArchivo}',
          senderName: nombre,
          sentAt: message.fecha,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.getValue<double>(
      context,
      mobile: 220,
      tablet: 280,
      desktop: 320,
    );

    if (_isLocal) {
      return GestureDetector(
        onTap: () => _openViewer(context, message.mensaje),
        child: Image.file(
          File(message.mensaje),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _ImageErrorBox(size: size),
        ),
      );
    }

    final url = MessageUrlHelper.buildFileUrl(message, idLead);
    return GestureDetector(
      onTap: () => _openViewer(context, url),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _ImagePlaceholder(size: size),
        errorWidget: (_, _, _) => _ImageErrorBox(size: size),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double size;
  const _ImagePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  final double size;
  const _ImageErrorBox({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoContent — placeholder de video con play
// ─────────────────────────────────────────────────────────────────────────────

class _VideoContent extends StatelessWidget {
  final ChatMessage message;
  final int idLead;
  final String nombre;

  const _VideoContent({
    required this.message,
    required this.idLead,
    required this.nombre,
  });

  bool get _isLocal => _isLocalFileHelper(message);

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.getValue<double>(
      context,
      mobile: 220,
      tablet: 280,
      desktop: 320,
    );

    final url = _isLocal
        ? message.mensaje
        : MessageUrlHelper.buildFileUrl(message, idLead);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => MediaViewerPage(
              url: url,
              fileName: '${message.nomArchivo}${message.extArchivo}',
              senderName: nombre,
              sentAt: message.fecha,
            ),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: _VideoThumbnailWidget(
        url: url,
        width: size,
        height: size * 0.65,
        fileName: '${message.nomArchivo}${message.extArchivo}',
      ),
    );
  }
}

// Widget separado porque necesita estado para el thumbnail
class _VideoThumbnailWidget extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final String fileName;

  const _VideoThumbnailWidget({
    required this.url,
    required this.width,
    required this.height,
    required this.fileName,
  });

  @override
  State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  Uint8List? _thumbnail;
  bool _loadingThumb = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: widget.width.toInt(),
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _thumbnail = bytes;
          _loadingThumb = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingThumb = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade900,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo: thumbnail, loading, o fallback
          if (_loadingThumb)
            // 👇 ESTO ES LO QUE CAMBIA — circulo mientras carga
            Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            )
          else if (_thumbnail != null)
            Image.memory(_thumbnail!, fit: BoxFit.cover)
          else
            // fallback si falla el thumbnail
            Container(
              color: Colors.grey.shade800,
              child: const Icon(
                Icons.videocam_rounded,
                size: 48,
                color: Colors.white24,
              ),
            ),

          // Overlay gradient (solo si hay thumbnail)
          if (!_loadingThumb)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // ignore: deprecated_member_use
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),

          // Botón play (solo si no está cargando)
          if (!_loadingThumb)
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

          // Nombre del archivo (solo si no está cargando)
          if (!_loadingThumb)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                widget.fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DocumentContent — descarga y abre archivo
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentContent extends StatefulWidget {
  final ChatMessage message;
  final int idLead;
  final Color textColor;

  const _DocumentContent({
    required this.message,
    required this.idLead,
    required this.textColor,
  });

  @override
  State<_DocumentContent> createState() => _DocumentContentState();
}

class _DocumentContentState extends State<_DocumentContent> {
  bool _isDownloading = false;
  double _progress = 0;

  IconData _iconForExt(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (e == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['xls', 'xlsx'].contains(e)) return Icons.table_chart_rounded;
    if (['doc', 'docx'].contains(e)) return Icons.description_rounded;
    if (['ppt', 'pptx'].contains(e)) return Icons.slideshow_rounded;
    if (['zip', 'rar'].contains(e)) return Icons.folder_zip_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Future<void> _downloadAndOpen() async {
    if (_isDownloading) return;

    // Archivo local recién seleccionado
    if (_isLocalFileHelper(widget.message)) {
      await OpenFilex.open(widget.message.mensaje);
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          '${widget.message.nomArchivo}${widget.message.extArchivo}';
      final savePath = '${dir.path}/$fileName';

      // Si ya existe localmente, abrir directo
      if (await File(savePath).exists()) {
        await OpenFilex.open(savePath);
        return;
      }

      final url = MessageUrlHelper.buildFileUrl(widget.message, widget.idLead);

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );

      await OpenFilex.open(savePath);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Error al abrir el archivo');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.message.isEnviado
        ? colorScheme.onPrimary
        : colorScheme.primary;

    return GestureDetector(
      onTap: _downloadAndOpen,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono o loader de progreso
            SizedBox(
              width: 28,
              height: 28,
              child: _isDownloading
                  ? CircularProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      strokeWidth: 2.5,
                      color: iconColor,
                    )
                  : Icon(
                      _iconForExt(widget.message.extArchivo),
                      size: 28,
                      color: iconColor,
                    ),
            ),

            const SizedBox(width: 10),

            // Nombre y estado
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.message.nomArchivo}${widget.message.extArchivo}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isDownloading ? 'Descargando...' : 'Toca para abrir',
                    style: TextStyle(
                      fontSize: 11,
                      // ignore: deprecated_member_use
                      color: widget.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TemplateContent — mensaje de plantilla: texto + imagen opcional
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateContent extends StatelessWidget {
  final ChatMessage message;
  final int idLead;
  final Color textColor;
  final AudioController audioController;
  final String nombre;

  const _TemplateContent({
    required this.message,
    required this.idLead,
    required this.textColor,
    required this.audioController,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        message.nomArchivo.isNotEmpty && MessageUrlHelper.isImage(message);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Texto del template
        if (message.mensaje.isNotEmpty)
          // Text(
          //   message.mensaje,
          //   style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
          // ),
          RichText(
            text: TextSpan(children: parseMensaje(message.mensaje, textColor)),
          ),

        // Imagen del template
        if (hasImage) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _ImageContent(
              message: message,
              idLead: idLead,
              nombre: nombre,
            ),
          ),
        ],
      ],
    );
  }
}
