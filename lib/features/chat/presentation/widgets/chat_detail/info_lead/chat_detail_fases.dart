import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailFases extends StatelessWidget {
  final String idEstadoActual;
  final void Function(LeadEstado estado) onEstadoTap;

  const ChatDetailFases({
    super.key,
    required this.idEstadoActual,
    required this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fase del lead', style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: LeadEstado.values.map((estado) {
              final isActivo = estado.id == idEstadoActual;
              final isUltimo = estado == LeadEstado.values.last;

              return Expanded(
                child: Row(
                  children: [
                    // ── Círculo + label ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onEstadoTap(estado),
                        child: Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActivo
                                    ? Colors.green
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isActivo
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isActivo
                                  ? const Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              estado.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isActivo
                                    ? Colors.green
                                    : Colors.grey.shade600,
                                fontWeight: isActivo
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Línea conectora ──
                    if (!isUltimo)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
