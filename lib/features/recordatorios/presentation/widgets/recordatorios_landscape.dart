// lib/features/recordatorios/presentation/widgets/home_landscape.dart

import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_state.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';

class RecordatoriosLandscape extends StatelessWidget {
  final RecordatoriosLoaded state;

  const RecordatoriosLandscape({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── COLUMNA IZQUIERDA: MENU ──────────────────────────
        Expanded(
          flex: 5,
          child: Text(
            'Aquí está el resumen de hoy',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        // Separador vertical
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // ── COLUMNA DERECHA: DATOS ───────────────────────────
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...state.recordatorios.map(
                  (lead) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(lead.nomApe),
                      subtitle: Text(
                        '${lead.accion} - ${lead.aviso} - ${lead.hora}',
                      ),
                      trailing: lead.comentario.isEmpty
                          ? null
                          : Text(lead.comentario),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
