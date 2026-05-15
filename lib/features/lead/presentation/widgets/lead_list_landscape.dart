import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter/material.dart';

class LeadListLandscape extends StatelessWidget {
  final LeadListLoaded state;
  const LeadListLandscape({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final leads = state.leads;

    // ── STATS ──────────────────────────────────────────────
    final hoy = DateTime.now();
    final leadsHoy = leads.where((l) {
      return l.numDia == hoy.day.toString().padLeft(2, '0') &&
          l.anho == hoy.year.toString();
    }).length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── COLUMNA IZQUIERDA: RESUMEN ─────────────────────
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── STAT CARDS ───────────────────────────
                _StatCard(
                  icon: Icons.group_outlined,
                  label: 'Total leads',
                  value: '${leads.length}',
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatCard(
                  icon: Icons.today_rounded,
                  label: 'Hoy',
                  value: '$leadsHoy',
                  // ignore: deprecated_member_use
                  color: Colors.green.shade900.withOpacity(0.3),
                  iconColor: Colors.green.shade400,
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatCard(
                  icon: Icons.history_rounded,
                  label: 'Anteriores',
                  value: '${leads.length - leadsHoy}',
                  color: colorScheme.surfaceContainerHighest,
                  iconColor: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(height: AppSpacing.lg),
                // ignore: deprecated_member_use
                Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                const SizedBox(height: AppSpacing.md),

                // ── ÚLTIMO LEAD ──────────────────────────
                if (leads.isNotEmpty) ...[
                  Text(
                    'Último lead',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _LastLeadCard(lead: leads.first),
                ],
              ],
            ),
          ),
        ),

        // ── SEPARADOR ──────────────────────────────────────
        VerticalDivider(
          width: 1,
          thickness: 1,
          // ignore: deprecated_member_use
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),

        // ── COLUMNA DERECHA: LISTA ──────────────────────────
        Expanded(
          flex: 6,
          child: leads.isEmpty
              ? const Center(
                  child: AppEmptyView(message: 'No hay leads registrados'),
                )
              : ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: leads.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 56,
                    // ignore: deprecated_member_use
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                  itemBuilder: (context, index) =>
                      _LeadRowTile(lead: leads[index]),
                ),
        ),
      ],
    );
  }
}

// ── STAT CARD ───────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ÚLTIMO LEAD CARD ────────────────────────────────────────
class _LastLeadCard extends StatelessWidget {
  final Lead lead;
  const _LastLeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lead ${lead.idLead}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Reciente',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.badge_outlined,
            text: lead.dni.isEmpty ? 'Sin DNI' : lead.dni,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: '${lead.dia} ${lead.numDia} ${lead.mes} ${lead.anho}',
          ),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.schedule_outlined, text: lead.hora),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── TILE DE LISTA ────────────────────────────────────────────
class _LeadRowTile extends StatelessWidget {
  final Lead lead;
  const _LeadRowTile({required this.lead});

  bool get _esHoy {
    final hoy = DateTime.now();
    return lead.numDia == hoy.day.toString().padLeft(2, '0') &&
        lead.anho == hoy.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── ÍCONO ────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _esHoy
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _esHoy ? Icons.person_add_rounded : Icons.person_outline_rounded,
              size: 18,
              color: _esHoy
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── ID + DNI ──────────────────────────────────────
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
                    if (_esHoy) ...[
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
                  lead.dni.isEmpty ? 'Sin DNI' : lead.dni,
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

          // ── FECHA ─────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _esHoy ? 'Hoy' : '${lead.numDia} ${lead.mes}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _esHoy
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: _esHoy ? FontWeight.w600 : FontWeight.normal,
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
    );
  }
}
