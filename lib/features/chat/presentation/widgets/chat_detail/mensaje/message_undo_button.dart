// lib/features/chat/presentation/widgets/chat_detail/mensaje/message_undo_button.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Botón "Deshacer" bajo un mensaje recién enviado (estado
/// `ChatMessage.estadoProgramado`). Muestra un anillo que se vacía durante
/// [duracion] y desaparece solo al terminar. El tiempo se calcula desde
/// [fechaEnvio] (no desde que se construye el widget), así un rebuild o un
/// scroll no reinicia la cuenta.
class MensajeDeshacerBoton extends StatefulWidget {
  final String fechaEnvio;
  final Duration duracion;
  final VoidCallback onDeshacer;

  const MensajeDeshacerBoton({
    super.key,
    required this.fechaEnvio,
    required this.duracion,
    required this.onDeshacer,
  });

  @override
  State<MensajeDeshacerBoton> createState() => _MensajeDeshacerBotonState();
}

class _MensajeDeshacerBotonState extends State<MensajeDeshacerBoton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _vencido = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duracion);

    final inicio = DateTime.tryParse(widget.fechaEnvio) ?? DateTime.now();
    final transcurrido = DateTime.now().difference(inicio);
    final totalMs = widget.duracion.inMilliseconds;
    final avance = totalMs > 0
        ? (transcurrido.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 1.0;

    if (avance >= 1.0) {
      _vencido = true;
      return;
    }

    _controller
      ..value = avance
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _vencido = true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vencido) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: colorScheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: AppSizing.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _controller.stop();
            widget.onDeshacer();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, _) => CircularProgressIndicator(
                      value: 1 - _controller.value,
                      strokeWidth: AppSizing.spinnerStrokeSmall,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: AppColors.opacitySubtle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  AppIcons.undo,
                  size: AppSizing.iconSm,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  'Deshacer',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.primary,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
