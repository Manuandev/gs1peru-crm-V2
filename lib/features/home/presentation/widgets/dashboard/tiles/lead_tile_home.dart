import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter/material.dart';

class LeadTileHome extends StatelessWidget {
  final Lead lead;
  const LeadTileHome({super.key, required this.lead});

  bool _esHoy(Lead lead) {
    final hoy = DateTime.now();
    return lead.numDia == hoy.day.toString().padLeft(2, '0') &&
        lead.anho == hoy.year.toString() &&
        lead.mes == _mesNombre(hoy.month);
  }

  String _mesNombre(int mes) {
    const nombres = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return nombres[mes];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esHoy = _esHoy(lead);
    final fechaLabel = esHoy ? 'Hoy' : '${lead.numDia} ${lead.mes}';
    final fuente = lead.dni.isEmpty ? 'Sin documento' : lead.dni;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // ── ICONO / INDICADOR ─────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: esHoy
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                esHoy ? Icons.person_add_rounded : Icons.person_outline_rounded,
                size: 20,
                color: esHoy
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── CONTENIDO CENTRAL ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lead ${lead.idLead}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (esHoy) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Nuevo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fuente,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── FECHA + HORA ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fechaLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: esHoy
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: esHoy ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
                Text(
                  lead.hora,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
