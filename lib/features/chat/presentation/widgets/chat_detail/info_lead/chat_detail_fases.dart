// lib/features/chat/presentation/widgets/chat_detail/info_lead/chat_detail_fases.dart
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailFases extends StatelessWidget {
  final String idEstadoActual;

  const ChatDetailFases({super.key, required this.idEstadoActual});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final estados = LeadEstado.values;
    final indexActivo = estados.indexWhere((e) => e.id == idEstadoActual);
    final activoEfectivo = indexActivo < 0 ? 0 : indexActivo;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(estados.length * 2 - 1, (i) {
          // índices pares → paso; índices impares → línea
          if (i.isOdd) {
            final pasoIzq = i ~/ 2;
            final lineaActiva = pasoIzq < activoEfectivo;
            return Expanded(
              child: Container(
                height: AppSizing.chatStepperLineHeight,
                color: lineaActiva ? colorScheme.primary : AppColors.grey300,
              ),
            );
          }

          final index = i ~/ 2;
          final estado = estados[index];
          final isActivo = index == activoEfectivo;
          final isPasado = index < activoEfectivo;

          return _PasoStepper(
            numero: index + 1,
            label: estado.label,
            isActivo: isActivo,
            isPasado: isPasado,
            colorActivo: colorScheme.primary,
          );
        }),
      ),
    );
  }
}

class _PasoStepper extends StatelessWidget {
  final int numero;
  final String label;
  final bool isActivo;
  final bool isPasado;
  final Color colorActivo;

  const _PasoStepper({
    required this.numero,
    required this.label,
    required this.isActivo,
    required this.isPasado,
    required this.colorActivo,
  });

  @override
  Widget build(BuildContext context) {
    final circleFill = isActivo ? colorActivo : AppColors.surface;
    final circleBorder = isActivo || isPasado ? colorActivo : AppColors.grey400;
    final numberColor = isActivo ? AppColors.textOnDark : (isPasado ? colorActivo : AppColors.grey400);
    final labelColor = isActivo ? colorActivo : AppColors.grey500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label arriba
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: labelColor,
            fontWeight: isActivo ? AppTextStyles.weightBold : AppTextStyles.weightRegular,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Círculo con número
        Container(
          width: AppSizing.chatStepperCircleSize,
          height: AppSizing.chatStepperCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleFill,
            border: Border.all(color: circleBorder, width: AppSizing.borderFocusWidth),
          ),
          child: Center(
            child: Text(
              '$numero',
              style: AppTextStyles.titleSmall.copyWith(
                color: numberColor,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
