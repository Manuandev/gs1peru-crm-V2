// lib/features/home/presentation/widgets/notifications/tiles/recordatorio_tile.dart

import 'package:flutter/material.dart';

import 'package:app_crm/features/home/index_home.dart';

class RecordatorioTile extends StatelessWidget {
  final Recordatorio recordatorio;

  const RecordatorioTile({super.key, required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre + fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                recordatorio.nombre,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                recordatorio.fechaHora,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            recordatorio.nombreEmpresa,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),

          // Teléfono + asignado
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(recordatorio.telefono, style: textTheme.bodySmall),
              const SizedBox(width: 16),
              Icon(
                Icons.person_outline,
                size: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  recordatorio.asignadoA,
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Acción + aviso (exclusivos de Recordatorio)
          Row(
            children: [
              Icon(
                Icons.bolt_outlined,
                size: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                recordatorio.accion,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(recordatorio.aviso, style: textTheme.bodySmall),
            ],
          ),

          // Comentario si existe
          if (recordatorio.comentario.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              recordatorio.comentario,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _Tag(
                label: recordatorio.campania,
                color: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
              ),
              _Tag(
                label: recordatorio.evento,
                color: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
              ),
              _Tag(
                label: recordatorio.canal,
                color: colorScheme.tertiaryContainer,
                textColor: colorScheme.onTertiaryContainer,
              ),
            ],
          ),
        ],
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
