// lead_tile.dart
import 'package:app_crm/core/constants/app_breakpoints.dart';
import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';
import 'package:flutter/material.dart';

class LeadTile extends StatelessWidget {
  final LeadItem lead;
  const LeadTile({super.key, required this.lead});

  String _mesNumero(String mes) {
    const meses = {
      'Enero': '01',
      'Febrero': '02',
      'Marzo': '03',
      'Abril': '04',
      'Mayo': '05',
      'Junio': '06',
      'Julio': '07',
      'Agosto': '08',
      'Septiembre': '09',
      'Octubre': '10',
      'Noviembre': '11',
      'Diciembre': '12',
    };
    return meses[mes] ?? '00';
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final diaHoy = hoy.day.toString().padLeft(2, '0');
    final mesHoy = hoy.month.toString().padLeft(2, '0');
    final anhoHoy = hoy.year.toString();

    final esHoy =
        lead.numDia == diaHoy &&
        lead.anho == anhoHoy &&
        _mesNumero(lead.mes) == mesHoy;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── FECHA/HORA ────────────────────────────────────
          Text(
            '${esHoy ? "Hoy" : "${lead.numDia} ${lead.mes}"} ${lead.hora}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── BADGE NUEVO ───────────────────────────────────
          if (esHoy)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(AppSizing.radiusXs),
              ),
              child: Text(
                '↑Nuevo!',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(width: AppSpacing.sm),

          // ── ID + FUENTE ───────────────────────────────────
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: 'Lead ${lead.idLead}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' — ${lead.dni.isEmpty ? "Sin fuente" : lead.dni}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
