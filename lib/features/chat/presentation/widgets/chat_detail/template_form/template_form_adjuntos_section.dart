// lib/features/chat/presentation/widgets/chat_detail/template_form/template_form_adjuntos_section.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

/// Sección "Adjuntos (imagen, documento, audio)" del formulario de plantilla.
///
/// Imagen y documento se eligen con el mismo picker que ya usa
/// `AttachmentPickerWidget`; audio se graba con `AudioRecorderWidget`
/// (ya existente en `widgets/chat_detail/audio/`) — pedido explícito del
/// usuario, para audio "hay que grabar" en vez de subir un archivo. Este
/// widget solo arma el `StagedFile` local (path del dispositivo) — la subida
/// real al servidor pasa recién al presionar "Guardar plantilla"
/// (`TemplateFormBloc.guardar`, no acá), así que no hace falta ningún estado
/// de carga propio de este picker.
class TemplateFormAdjuntosSection extends StatelessWidget {
  // Únicos tipos de "documento" que la API de WhatsApp acepta enviar — mismo
  // criterio que AttachmentPickerWidget (envío de archivos en el chat), ver
  // chat/CLAUDE.md.
  static const _docExts = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];

  final StagedFile? archivo;
  final bool grabando;
  // false cuando ya hay más de 3 botones agregados — con archivo adjunto el
  // tope de botones baja a 3 (ver template_form_view.dart), así que no se
  // debe permitir adjuntar si ese tope ya está superado.
  final bool puedeAdjuntar;
  // false cuando ya hay texto escrito en la descripción — "no se puede
  // enviar audio junto con texto" (regla confirmada por el usuario), así que
  // la opción "Grabar audio" del bottom sheet queda deshabilitada mientras
  // haya descripción (ver template_form_view.dart._puedeGrabarAudio).
  final bool puedeGrabarAudio;
  // true mientras se guarda la plantilla completa (subida de archivo + CUD,
  // ver TemplateFormBloc.guardar) — bloquea el círculo de subir para que no
  // se cambie el adjunto a mitad de un guardado ya en curso.
  final bool subiendo;
  final ValueChanged<StagedFile> onArchivoSeleccionado;
  final VoidCallback onQuitarArchivo;
  final VoidCallback onIniciarGrabacion;
  final VoidCallback onCancelarGrabacion;

  const TemplateFormAdjuntosSection({
    super.key,
    required this.archivo,
    required this.grabando,
    required this.puedeAdjuntar,
    required this.puedeGrabarAudio,
    this.subiendo = false,
    required this.onArchivoSeleccionado,
    required this.onQuitarArchivo,
    required this.onIniciarGrabacion,
    required this.onCancelarGrabacion,
  });

  void _emitirArchivo(String path, String tipo) {
    final nombreCompleto = path.split(RegExp(r'[\\/]')).last;
    final punto = nombreCompleto.lastIndexOf('.');
    final nombre = punto > 0 ? nombreCompleto.substring(0, punto) : nombreCompleto;
    final ext = punto > 0 ? nombreCompleto.substring(punto) : '';
    final file = File(path);

    onArchivoSeleccionado(
      StagedFile(
        path: path,
        nameWithoutExt: nombre,
        ext: ext,
        tipo: tipo,
        sizeBytes: file.existsSync() ? file.lengthSync() : 0,
      ),
    );
  }

  Future<void> _elegirOrigen(BuildContext context) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.image),
              title: const Text('Imagen'),
              onTap: () => Navigator.of(ctx).pop('imagen'),
            ),
            ListTile(
              leading: const Icon(AppIcons.fileOutlined),
              title: const Text('Documento'),
              onTap: () => Navigator.of(ctx).pop('documento'),
            ),
            ListTile(
              leading: const Icon(AppIcons.mic),
              title: const Text('Grabar audio'),
              enabled: puedeGrabarAudio,
              onTap: puedeGrabarAudio
                  ? () => Navigator.of(ctx).pop('audio')
                  : null,
            ),
          ],
        ),
      ),
    );

    if (opcion == null || !context.mounted) return;

    switch (opcion) {
      case 'imagen':
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) _emitirArchivo(picked.path, 'image');
      case 'documento':
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: _docExts,
        );
        final path = result?.files.single.path;
        if (path != null) _emitirArchivo(path, 'document');
      case 'audio':
        onIniciarGrabacion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (grabando) {
      return AudioRecorderWidget(
        onAudioReady: (path) => _emitirArchivo(path, 'audio'),
        onCancel: onCancelarGrabacion,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Adjuntos (imagen, documento, audio)'),
        const SizedBox(height: AppSpacing.sm),
        if (archivo == null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: AppSizing.hairline,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sin archivos adjuntos',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (puedeAdjuntar && !subiendo)
                      ? () => _elegirOrigen(context)
                      : null,
                  child: Container(
                    width: AppSizing.iconContainerMd,
                    height: AppSizing.iconContainerMd,
                    decoration: BoxDecoration(
                      color: (puedeAdjuntar && !subiendo)
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: subiendo
                        ? Padding(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            child: CircularProgressIndicator(
                              strokeWidth: AppSizing.spinnerStrokeSmall,
                              color: AppColors.textOnDark,
                            ),
                          )
                        : Icon(
                            AppIcons.upload,
                            size: AppSizing.iconActionSm,
                            color: AppColors.textOnDark,
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (!puedeAdjuntar)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                'Con más de 3 botones no se puede adjuntar un archivo.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (!puedeGrabarAudio)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                'No se puede grabar audio con texto ya escrito en la descripción.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ] else ...[
          TemplateFileCard(
            nombre: archivo!.nameWithoutExt,
            ext: archivo!.ext,
            sizeBytes: archivo!.sizeBytes,
            detailed: true,
            onRemove: onQuitarArchivo,
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              'Solo se permite un archivo por plantilla — sube uno nuevo para reemplazarlo.',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
