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
///
/// Reglas adicionales confirmadas por el usuario:
/// - No se puede agregar un botón nuevo si algún botón ya agregado quedó sin
///   texto (hay que completarlo primero).
/// - Los botones solo se pueden crear con descripción ya escrita
///   ([hayDescripcion]).
/// - Con audio grabando/adjunto ([bloqueadoPorAudio]) toda la sección queda
///   bloqueada — "no se puede enviar audio junto con texto" también aplica a
///   botones (ver template_form_view.dart._bloqueadoPorAudio).
class TemplateFormBotonesSection extends StatelessWidget {
  final List<TextEditingController> botonesCtrls;
  final int maxBotones;
  final bool hayDescripcion;
  final bool bloqueadoPorAudio;
  final VoidCallback onAgregar;
  final ValueChanged<int> onQuitar;

  const TemplateFormBotonesSection({
    super.key,
    required this.botonesCtrls,
    required this.maxBotones,
    required this.hayDescripcion,
    required this.bloqueadoPorAudio,
    required this.onAgregar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final llegoAlTope = botonesCtrls.length >= maxBotones;
    final hayBotonVacio = botonesCtrls.any((c) => c.text.trim().isEmpty);
    final puedeAgregar = !bloqueadoPorAudio &&
        hayDescripcion &&
        !hayBotonVacio &&
        !llegoAlTope;

    String? mensaje;
    if (bloqueadoPorAudio) {
      mensaje = 'No se pueden usar botones junto con un audio adjunto.';
    } else if (!hayDescripcion) {
      mensaje = 'Escribe la descripción antes de agregar botones.';
    } else if (hayBotonVacio) {
      mensaje = 'Completa el texto del botón anterior antes de agregar otro.';
    } else if (llegoAlTope) {
      mensaje =
          'Máximo $maxBotones botones${maxBotones == 3 ? ' con archivo adjunto' : ''}.';
    }

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
                    enabled: !bloqueadoPorAudio,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  visualDensity: VisualDensity.compact,
                  onPressed: bloqueadoPorAudio ? null : () => onQuitar(i),
                ),
              ],
            ),
          ),
        CustomTextButton(
          text: 'Agregar botón',
          icon: const Icon(AppIcons.add),
          onPressed: puedeAgregar ? onAgregar : null,
        ),
        if (mensaje != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              mensaje,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
