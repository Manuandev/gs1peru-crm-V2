// lib/features/chat/presentation/widgets/chat_detail/template_form/template_form_botones_section.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Sección "+ Agregar botón". Confirmado por el usuario: no hay tipos de
/// botón (quick reply/URL/teléfono) — lo único configurable por botón es su
/// texto (ej. "Sí" / "No"), eso es todo lo que se guarda.
///
/// Tope de botones (regla de negocio confirmada por el usuario): **6** si la
/// plantilla no tiene archivo adjunto, **3** si sí tiene (imagen/documento/
/// audio) — [maxBotones] ya llega calculado desde `template_form_view.dart`
/// según haya o no `_archivo`.
class TemplateFormBotonesSection extends StatelessWidget {
  final List<TextEditingController> botonesCtrls;
  final int maxBotones;
  final VoidCallback onAgregar;
  final ValueChanged<int> onQuitar;

  const TemplateFormBotonesSection({
    super.key,
    required this.botonesCtrls,
    required this.maxBotones,
    required this.onAgregar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final llegoAlTope = botonesCtrls.length >= maxBotones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Botones'),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < botonesCtrls.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: botonesCtrls[i],
                    hint: 'Texto del botón',
                    dense: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onQuitar(i),
                ),
              ],
            ),
          ),
        CustomTextButton(
          text: 'Agregar botón',
          icon: const Icon(AppIcons.add),
          onPressed: llegoAlTope ? null : onAgregar,
        ),
        if (llegoAlTope)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              'Máximo $maxBotones botones${maxBotones == 3 ? ' con archivo adjunto' : ''}.',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
