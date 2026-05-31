// lib/features/home/presentation/widgets/notifications/tiles/lead_nuevo_tile.dart

import 'package:flutter/material.dart';
import 'package:app_crm/features/home/index_home.dart';

class LeadNuevoTile extends StatelessWidget {
  final LeadNuevo lead;

  const LeadNuevoTile({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: (){},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lead.nombre,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    lead.fechaHora,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Text(
                lead.nombreEmpresa,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    // ← cambia Text por Flexible
                    child: Text(
                      lead.telefono,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person_outline,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.asignadoA,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Tag(
                    label: lead.campania,
                    color: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                  ),
                  _Tag(
                    label: lead.evento,
                    color: colorScheme.secondaryContainer,
                    textColor: colorScheme.onSecondaryContainer,
                  ),
                  _Tag(
                    label: lead.canal,
                    color: colorScheme.tertiaryContainer,
                    textColor: colorScheme.onTertiaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
