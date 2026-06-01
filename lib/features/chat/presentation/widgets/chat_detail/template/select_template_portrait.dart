// lib/features/chat/presentation/widgets/chat_detail/template/select_template_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class SelectTemplatePortrait extends StatefulWidget {
  final SelectTemplateLoaded state;

  const SelectTemplatePortrait({super.key, required this.state});

  @override
  State<SelectTemplatePortrait> createState() => _SelectTemplatePortraitState();
}

class _SelectTemplatePortraitState extends State<SelectTemplatePortrait> {
  Template? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.state.templates.isEmpty) return const _EmptyTemplate();

    return Column(
      children: [
        // ── Lista de cards ────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: widget.state.templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final template = widget.state.templates[index];
              final isSelected = _selected?.idPlantilla == template.idPlantilla;

              return _TemplateCard(
                template: template,
                isSelected: isSelected,
                onTap: () => setState(() => _selected = template),
              );
            },
          ),
        ),

        // ── Botón enviar ──────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _selected != null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selected == null
                      ? null
                      : () => context.goBack<Template>(_selected),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar plantilla'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── Card individual ───────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final Template template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final tieneArchivo = template.rutaArchivo.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ícono tipo ──────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tieneArchivo
                    ? _iconForExt(template.extensionArchivo)
                    : Icons.chat_bubble_outline_rounded,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // ── Nombre + preview ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.nombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (template.detalle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      template.detalle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (tieneArchivo) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          template.nombreArchivo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Check seleccionado ──────────────────────────
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForExt(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(e)) {
      return Icons.image_outlined;
    }
    if (['mp4', 'mov', 'avi'].contains(e)) return Icons.videocam_outlined;
    if (['mp3', 'm4a', 'ogg', 'wav'].contains(e)) return Icons.mic_outlined;
    if (['pdf'].contains(e)) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTemplate extends StatelessWidget {
  const _EmptyTemplate();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No hay plantillas',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
