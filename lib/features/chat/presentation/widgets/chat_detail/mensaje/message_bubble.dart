// lib/features/chat/presentation/widgets/chat_detail/mensaje/message_bubble.dart

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
  final m = msg.contenido;
  return m.isNotEmpty &&
      (m.startsWith('/') || m.startsWith('file://') || m.contains(r':\'));
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AudioController audioController;
  final int idNumero;
  final String nombre;

  const MessageBubble({
    super.key,
    required this.message,
    required this.audioController,
    required this.idNumero,
    required this.nombre,
  });

  bool get _isImageMsg =>
      !MessageUrlHelper.isPlantillaFile(message) &&
      MessageUrlHelper.isImage(message);
  bool get _isVideoMsg =>
      !MessageUrlHelper.isPlantillaFile(message) &&
      MessageUrlHelper.isVideo(message);
  bool get _isMediaMsg => _isImageMsg || _isVideoMsg;
  bool get _isLocalFile => _isLocalFileHelper(message);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAIA = message.direccionMensaje == 'AIA';
    final isEnviado = message.direccionMensaje == 'ASE' || isAIA;

    final bubbleColor = isEnviado
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isEnviado ? colorScheme.onPrimary : colorScheme.onSurface;

    final burbuja = Container(
      margin: EdgeInsets.only(
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxs,
        // Para AIA el avatar ocupa el espacio izquierdo; para ASE usamos xxl
        left: isAIA ? 0 : (isEnviado ? AppSpacing.xxl : 0),
        right: isEnviado ? 0 : AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: _bubbleRadius(isEnviado),
        boxShadow: [
          BoxShadow(
            color: AppColors.black(0.06),
            blurRadius: AppSizing.shadowBlurXs,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: _isMediaMsg
            ? const EdgeInsets.all(AppSpacing.xxs)
            : EdgeInsets.zero,
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
                        fecha: message.fechaHora,
                        estado: message.estadoEntrega,
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
                      fecha: message.fechaHora,
                      estado: message.estadoEntrega,
                      isEnviado: isEnviado,
                      isOverImage: false,
                      textColor: textColor,
                    ),
                  ],
                ),
        ),
      ),
    );

    // Mensajes del bot (AIA): burbuja a la derecha con avatar de robot a su derecha
    if (isAIA) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: burbuja,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const _BotAvatar(),
        ],
      );
    }

    return Align(
      alignment: isEnviado ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: burbuja,
      ),
    );
  }

  BorderRadius _bubbleRadius(bool isEnviado) {
    return BorderRadius.only(
      topLeft: const Radius.circular(AppSizing.radiusLg),
      topRight: const Radius.circular(AppSizing.radiusLg),
      bottomLeft: Radius.circular(
        isEnviado ? AppSizing.radiusLg : AppSizing.radiusXs,
      ),
      bottomRight: Radius.circular(
        isEnviado ? AppSizing.radiusXs : AppSizing.radiusLg,
      ),
    );
  }

  BorderRadius _innerBubbleRadius(bool isEnviado) {
    // Si la burbuja externa tiene 16px de radio y 2px de padding, la interna debería tener ~14px.
    return BorderRadius.only(
      topLeft: const Radius.circular(AppSizing.radiusBubbleInner),
      topRight: const Radius.circular(AppSizing.radiusBubbleInner),
      bottomLeft: Radius.circular(
        isEnviado
            ? AppSizing.radiusBubbleInner
            : AppSizing.radiusBubbleTipInner,
      ),
      bottomRight: Radius.circular(
        isEnviado
            ? AppSizing.radiusBubbleTipInner
            : AppSizing.radiusBubbleInner,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    // Archivo de plantilla (\PLANTILLAS\) → vista unificada sin importar el tipo del mensaje
    if (MessageUrlHelper.isPlantillaFile(message) &&
        message.nombreArchivo.isNotEmpty) {
      return _PlantillaArchivoContent(
        message: message,
        idNumero: idNumero,
        textColor: textColor,
        audioController: audioController,
        nombre: nombre,
      );
    }

    switch (message.tipo) {
      case 'image':
        return _ImageContent(
          message: message,
          idNumero: idNumero,
          nombre: nombre,
        );

      case 'audio':
        final path = _isLocalFile
            ? message.contenido
            : MessageUrlHelper.buildFileUrl(message, idNumero);
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm2,
            AppSpacing.sm,
            AppSpacing.sm2,
            AppSpacing.xs,
          ),
          child: AudioPlayerWidget(
            audioPath: path,
            isEnviado:
                message.direccionMensaje == 'ASE' ||
                message.direccionMensaje == 'AIA',
            audioController: audioController,
          ),
        );

      case 'video':
        return _VideoContent(
          message: message,
          idNumero: idNumero,
          nombre: nombre,
        );

      case 'document':
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm2,
            AppSpacing.sm,
            AppSpacing.sm2,
            AppSpacing.xs,
          ),
          child: _DocumentContent(
            message: message,
            idNumero: idNumero,
            textColor: textColor,
          ),
        );

      // case 'template':
      //   return Padding(
      //     padding: const EdgeInsets.fromLTRB(AppSpacing.sm2, AppSpacing.sm, AppSpacing.sm2, AppSpacing.xs),
      //     child: _TemplateContent(message: message, idNumero: idNumero, textColor: textColor,
      //       audioController: audioController, nombre: nombre),
      //   );

      // text, button y cualquier otro tipo → texto plano
      case 'text':
      case 'button':
      default:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm2,
            AppSpacing.sm,
            AppSpacing.sm2,
            AppSpacing.xs,
          ),
          child: RichText(
            text: TextSpan(
              children: parseMensaje(message.contenido, textColor),
            ),
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
        ? AppColors.textOnDark
        : textColor.withValues(alpha: AppColors.opacityTimestamp);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fecha.formatDate(AppDateFormat.hourMinute),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: AppTextStyles.sizeSub,
            color: timeColor,
          ),
        ),
        if (isEnviado) ...[
          const SizedBox(width: AppSpacing.xs),
          MessageStatusIcon(
            estado: estado,
            color: isOverImage ? AppColors.textOnDark : textColor,
          ),
        ],
      ],
    );

    if (isOverImage) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          0,
          AppSpacing.sm,
          AppSpacing.chipGap,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.chipGap,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.black(0.45),
            borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
          ),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm2,
        AppSpacing.xxs,
        AppSpacing.sm2,
        AppSpacing.chipGap,
      ),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ImageContent — imagen inline con visor
// ─────────────────────────────────────────────────────────────────────────────

class _ImageContent extends StatelessWidget {
  final ChatMessage message;
  final int idNumero;
  final String nombre;

  const _ImageContent({
    required this.message,
    required this.idNumero,
    required this.nombre,
  });

  bool get _isLocal => _isLocalFileHelper(message);

  void _openViewer(BuildContext context, String urlOrPath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MediaViewerPage(
          url: urlOrPath,
          fileName: '${message.nombreArchivo}${message.tipoArchivo}',
          senderName: nombre,
          sentAt: message.fechaHora,
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
        onTap: () => _openViewer(context, message.contenido),
        child: Image.file(
          File(message.contenido),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _ImageErrorBox(size: size),
        ),
      );
    }

    final url = MessageUrlHelper.buildFileUrl(message, idNumero);
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
      color: AppColors.grey200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: AppSizing.spinnerStrokeSmall,
        ),
      ),
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
      color: AppColors.grey200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.brokenImage,
            size: AppSizing.iconXl,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Imagen no disponible',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
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
  final int idNumero;
  final String nombre;

  const _VideoContent({
    required this.message,
    required this.idNumero,
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
        ? message.contenido
        : MessageUrlHelper.buildFileUrl(message, idNumero);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => MediaViewerPage(
              url: url,
              fileName: '${message.nombreArchivo}${message.tipoArchivo}',
              senderName: nombre,
              sentAt: message.fechaHora,
            ),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: _VideoThumbnailWidget(
        url: url,
        isLocal: _isLocal,
        width: size,
        height: size * 0.65,
        fileName: '${message.nombreArchivo}${message.tipoArchivo}',
      ),
    );
  }
}

// Widget separado porque necesita estado para el thumbnail
class _VideoThumbnailWidget extends StatefulWidget {
  final String url;
  final bool isLocal;
  final double width;
  final double height;
  final String fileName;

  const _VideoThumbnailWidget({
    required this.url,
    required this.isLocal,
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
      Uint8List? bytes;

      if (widget.isLocal) {
        // ── Archivo local: thumbnail instantáneo desde el path ──
        bytes = await VideoThumbnail.thumbnailData(
          video: widget.url, // path absoluto, ej: /data/.../video.mp4
          imageFormat: ImageFormat.JPEG,
          maxWidth: widget.width.toInt(),
          quality: 75,
        );
      } else {
        // ── Archivo remoto: jala desde la URL del servidor ──
        // Solo intentar si la URL parece válida (ya confirmado por BD)
        bytes = await VideoThumbnail.thumbnailData(
          video: widget.url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: widget.width.toInt(),
          quality: 75,
        );
      }

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
      color: AppColors.grey900,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo: thumbnail, loading, o fallback
          if (_loadingThumb)
            // 👇 ESTO ES LO QUE CAMBIA — circulo mientras carga
            Container(
              color: AppColors.grey800,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
                  color: AppColors.white(0.54),
                ),
              ),
            )
          else if (_thumbnail != null)
            Image.memory(_thumbnail!, fit: BoxFit.cover)
          else
            // fallback si falla el thumbnail
            Container(
              color: AppColors.grey800,
              child: Icon(
                AppIcons.videocam,
                size: AppSizing.iconXl,
                color: AppColors.white(AppColors.opacityPressedOnDark),
              ),
            ),

          // Overlay gradient (solo si hay thumbnail)
          if (!_loadingThumb)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.transparent, AppColors.black(0.5)],
                ),
              ),
            ),

          // Botón play (solo si no está cargando)
          if (!_loadingThumb)
            Center(
              child: Container(
                width: AppSizing.videoPlayButton,
                height: AppSizing.videoPlayButton,
                decoration: BoxDecoration(
                  color: AppColors.black(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white(AppColors.opacityBorderOnDark),
                    width: AppSizing.animRingStroke,
                  ),
                ),
                child: Icon(
                  AppIcons.play,
                  color: AppColors.textOnDark,
                  size: AppSizing.iconLg,
                ),
              ),
            ),

          // Nombre del archivo (solo si no está cargando)
          if (!_loadingThumb)
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Text(
                widget.fileName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white(0.70),
                  fontSize: AppTextStyles.sizeXs,
                  shadows: [
                    Shadow(
                      color: AppColors.black(1.0),
                      blurRadius: AppSizing.shadowBlurXs,
                    ),
                  ],
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
  final int idNumero;
  final Color textColor;

  const _DocumentContent({
    required this.message,
    required this.idNumero,
    required this.textColor,
  });

  @override
  State<_DocumentContent> createState() => _DocumentContentState();
}

class _DocumentContentState extends State<_DocumentContent> {
  bool _isDownloading = false;
  double _progress = 0;

  // TODO: thumbnail PDF — descomentar cuando el jefe apruebe
  // Uint8List? _pdfThumb;
  // bool _loadingThumb = false;
  // bool get _isPdf =>
  //     widget.message.tipoArchivo.toLowerCase().replaceAll('.', '') == 'pdf';
  // @override
  // void initState() { super.initState(); if (_isPdf && !_isLocalFileHelper(widget.message)) _loadPdfThumb(); }
  // Future<void> _loadPdfThumb() async { ... }

  IconData _iconForExt(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (e == 'pdf') return AppIcons.pdf;
    if (['xls', 'xlsx'].contains(e)) return AppIcons.fileExcel;
    if (['doc', 'docx'].contains(e)) return AppIcons.fileWord;
    if (['ppt', 'pptx'].contains(e)) return AppIcons.filePowerpoint;
    if (['zip', 'rar'].contains(e)) return AppIcons.fileZip;
    return AppIcons.fileGeneric;
  }

  Color _colorForExt(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (e == 'pdf') return AppColors.error;
    if (['xls', 'xlsx'].contains(e)) return AppColors.success;
    if (['doc', 'docx'].contains(e)) return AppColors.info;
    if (['ppt', 'pptx'].contains(e)) return AppColors.secondary;
    if (['zip', 'rar'].contains(e)) return AppColors.warning;
    return AppColors.grey500;
  }

  String _labelForExt(String ext) =>
      ext.toLowerCase().replaceAll('.', '').toUpperCase();

  Future<void> _downloadAndOpen() async {
    if (_isDownloading) return;

    // Archivo local recién seleccionado
    if (_isLocalFileHelper(widget.message)) {
      await OpenFilex.open(widget.message.contenido);
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          '${widget.message.nombreArchivo}${widget.message.tipoArchivo}';
      final savePath = '${dir.path}/$fileName';

      // Si ya existe localmente, abrir directo
      if (await File(savePath).exists()) {
        await OpenFilex.open(savePath);
        return;
      }

      final url = MessageUrlHelper.buildFileUrl(
        widget.message,
        widget.idNumero,
      );

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
    final tipoColor = _colorForExt(widget.message.tipoArchivo);
    final label = _labelForExt(widget.message.tipoArchivo);

    return GestureDetector(
      onTap: _downloadAndOpen,
      child: _buildIconLayout(label, tipoColor),
    );
  }

  // Layout documento: cuadrado de color + nombre (PDF incluido por ahora)
  Widget _buildIconLayout(String label, Color tipoColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizing.iconFileContainer,
          height: AppSizing.iconFileContainer,
          decoration: BoxDecoration(
            color: tipoColor,
            borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
          ),
          child: _isDownloading
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.smPlus),
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    strokeWidth: AppSizing.spinnerStrokeLight,
                    color: AppColors.textOnDark,
                  ),
                )
              : Icon(
                  _iconForExt(widget.message.tipoArchivo),
                  size: AppSizing.iconMd,
                  color: AppColors.textOnDark,
                ),
        ),
        const SizedBox(width: AppSpacing.smPlus),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.message.nombreArchivo}${widget.message.tipoArchivo}',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmPlus,
                  color: widget.textColor,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _isDownloading ? 'Descargando...' : label,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXs,
                  color: widget.textColor.withValues(
                    alpha: AppColors.opacityTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// TODO: thumbnail PDF — descomentar cuando el jefe apruebe
// class _PdfThumbLoading extends StatelessWidget { ... }
// class _PdfThumbProgress extends StatelessWidget { ... }
// class _PdfThumbFallback extends StatelessWidget { ... }

// ─────────────────────────────────────────────────────────────────────────────
// _BotAvatar — ícono circular del asistente IA, aparece junto a mensajes AIA
// ─────────────────────────────────────────────────────────────────────────────

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      decoration: const BoxDecoration(
        color: AppColors.brandLavenderAccessible,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        AppIcons.ia,
        size: AppSizing.iconSm,
        color: AppColors.textOnDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlantillaArchivoContent — archivo de plantilla (\PLANTILLAS\):
// imagen / video / audio / documento arriba + texto abajo
// ─────────────────────────────────────────────────────────────────────────────

class _PlantillaArchivoContent extends StatelessWidget {
  final ChatMessage message;
  final int idNumero;
  final Color textColor;
  final AudioController audioController;
  final String nombre;

  const _PlantillaArchivoContent({
    required this.message,
    required this.idNumero,
    required this.textColor,
    required this.audioController,
    required this.nombre,
  });

  Widget _buildArchivo(BuildContext context) {
    if (MessageUrlHelper.isImage(message)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        child: _ImageContent(
          message: message,
          idNumero: idNumero,
          nombre: nombre,
        ),
      );
    }

    if (MessageUrlHelper.isVideo(message)) {
      return _VideoContent(
        message: message,
        idNumero: idNumero,
        nombre: nombre,
      );
    }

    if (MessageUrlHelper.isAudio(message)) {
      final url = MessageUrlHelper.buildFileUrl(message, idNumero);
      return AudioPlayerWidget(
        audioPath: url,
        isEnviado:
            message.direccionMensaje == 'ASE' ||
            message.direccionMensaje == 'AIA',
        audioController: audioController,
      );
    }

    return _DocumentContent(
      message: message,
      idNumero: idNumero,
      textColor: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneTexto = message.contenido.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm2,
        AppSpacing.sm,
        AppSpacing.sm2,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArchivo(context),
          if (tieneTexto) ...[
            const SizedBox(height: AppSpacing.sm),
            RichText(
              text: TextSpan(
                children: parseMensaje(message.contenido, textColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TemplateContent — COMENTADO: detección migrada a _PlantillaArchivoContent
// ─────────────────────────────────────────────────────────────────────────────

// class _TemplateContent extends StatelessWidget {
//   final ChatMessage message;
//   final int idNumero;
//   final Color textColor;
//   final AudioController audioController;
//   final String nombre;
//
//   const _TemplateContent({...});
//
//   @override
//   Widget build(BuildContext context) { ... }
// }
