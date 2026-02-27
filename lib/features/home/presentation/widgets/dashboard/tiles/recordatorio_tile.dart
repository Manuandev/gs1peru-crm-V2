// lead_tile.dart

import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:flutter/material.dart';

class RecordatorioTile extends StatelessWidget {
  final RecordatorioItem recordatorio;
  const RecordatorioTile({super.key, required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    // Color del ícono según acción
    final iconColor = recordatorio.accion.toLowerCase().contains('Enviar WhatsApp')
        ? Colors.green
        : Colors.blue;

    final icon = recordatorio.accion.toLowerCase().contains('Enviar WhatsApp')
        ? AppIcons.chat // o tu ícono de whatsapp
        : AppIcons.phone;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── ÍCONO ────────────────────────────────────────
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── HORA + ACCIÓN + NOMBRE ────────────────────────
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '${recordatorio.hora}  ',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: recordatorio.accion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' — ${recordatorio.modalidad}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}