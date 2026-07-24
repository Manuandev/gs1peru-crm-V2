// lib/features/chat/presentation/widgets/chat_detail/template_form/template_form_descripcion_section.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Sección "Descripción" — toolbar de negrita/cursiva/tachado (formato
/// WhatsApp: envuelve la selección con *texto*/_texto_/~texto~, o si no hay
/// selección inserta el par de marcadores con el cursor al medio, listo
/// para escribir) + emojis + botón "+ Variable" que inserta las mismas 3
/// variables que ya reemplaza `_formatear` en select_template_modal.dart.
class TemplateFormDescripcionSection extends StatelessWidget {
  final TextEditingController controller;

  const TemplateFormDescripcionSection({super.key, required this.controller});

  static const _variables = [
    ('{{nombre_cliente}}', 'nombre_cliente'),
    ('{{apellido_cliente}}', 'apellido_cliente'),
    ('{{nombre_asesor}}', 'nombre_asesor'),
  ];

  static const _emojis = [
    '😀', '😄', '😁', '😂', '🙂', '😉', '😍', '👍', '👎', '🙏',
    '🎉', '✅', '❌', '⭐', '❤️', '🔥', '📌', '📅', '⏰', '💬',
  ];

  void _insertarTexto(String texto) {
    final selection = controller.selection;
    final actual = controller.text;
    final inicio = selection.isValid ? selection.start : actual.length;
    final fin = selection.isValid ? selection.end : actual.length;
    final nuevo = actual.replaceRange(inicio, fin, texto);

    controller.value = TextEditingValue(
      text: nuevo,
      selection: TextSelection.collapsed(offset: inicio + texto.length),
    );
  }

  void _envolverSeleccion(String marcador) {
    final selection = controller.selection;
    final texto = controller.text;

    if (!selection.isValid || selection.isCollapsed) {
      // Sin texto seleccionado: inserta el par de marcadores en el cursor y
      // deja el cursor al medio, listo para escribir.
      final cursor = selection.isValid ? selection.start : texto.length;
      final nuevo = texto.replaceRange(cursor, cursor, '$marcador$marcador');
      controller.value = TextEditingValue(
        text: nuevo,
        selection: TextSelection.collapsed(offset: cursor + marcador.length),
      );
      return;
    }

    final seleccionado = texto.substring(selection.start, selection.end);
    final nuevo = texto.replaceRange(
      selection.start,
      selection.end,
      '$marcador$seleccionado$marcador',
    );

    controller.value = TextEditingValue(
      text: nuevo,
      selection: TextSelection.collapsed(
        offset: selection.end + marcador.length * 2,
      ),
    );
  }

  Future<void> _abrirEmojis(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final emoji in _emojis)
                InkWell(
                  onTap: () => _insertarTexto(emoji),
                  borderRadius: BorderRadius.circular(AppSizing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: FormSectionTitle('Descripción')),
            PopupMenuButton<String>(
              tooltip: 'Insertar variable',
              onSelected: _insertarTexto,
              itemBuilder: (_) => [
                for (final v in _variables)
                  PopupMenuItem(value: v.$1, child: Text(v.$2)),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.add,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Variable',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(AppIcons.boldText),
              tooltip: 'Negrita',
              visualDensity: VisualDensity.compact,
              onPressed: () => _envolverSeleccion('*'),
            ),
            IconButton(
              icon: const Icon(AppIcons.italicText),
              tooltip: 'Cursiva',
              visualDensity: VisualDensity.compact,
              onPressed: () => _envolverSeleccion('_'),
            ),
            IconButton(
              icon: const Icon(AppIcons.strikethroughText),
              tooltip: 'Tachado',
              visualDensity: VisualDensity.compact,
              onPressed: () => _envolverSeleccion('~'),
            ),
            IconButton(
              icon: const Icon(AppIcons.emoji),
              tooltip: 'Emojis',
              visualDensity: VisualDensity.compact,
              onPressed: () => _abrirEmojis(context),
            ),
          ],
        ),
        CustomTextField(
          controller: controller,
          hint: 'Escribe el contenido de la plantilla...',
          maxLines: 6,
          minLines: 4,
        ),
      ],
    );
  }
}
