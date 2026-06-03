// lib/features/lead/presentation/widgets/lead_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onStarTap;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onWhatsAppTap,
    this.onChatTap,
    this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila superior: avatar + info + hora/badge ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadAvatar(lead: lead),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _LeadInfo(lead: lead)),
                _LeadTimestamp(lead: lead),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Botones de acción ────────────────────────────────────────
            LeadCardActions(
              lead: lead,
              onWhatsAppTap: onWhatsAppTap,
              onChatTap: onChatTap,
              onStarTap: onStarTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar con fallback a iniciales
// ─────────────────────────────────────────────────────────────────────────────

class _LeadAvatar extends StatelessWidget {
  final Lead lead;

  const _LeadAvatar({required this.lead});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AvatarUtils.color(lead.nombreCompleto),
      child: Text(
        AvatarUtils.initials(lead.nombreCompleto),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info central: nombre + canal, empresa
// ─────────────────────────────────────────────────────────────────────────────

class _LeadInfo extends StatelessWidget {
  final Lead lead;

  const _LeadInfo({required this.lead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeText = theme.textTheme;

    final labelSmallStyle = themeText.labelSmall?.copyWith(
      color: themeText.labelSmall!.color,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                lead.nombreCompleto,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (lead.idCanal > 0) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIconsSocial.widgetCanal(lead.idCanal),
                  SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      CanalHelper.get(lead.idCanal).nombre,
                      style: labelSmallStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${lead.canal ?? 'Sin canal'} · ${lead.interes ?? 'Sin interés'}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          lead.nombreEmpresa.isEmpty ? 'Sin empresa' : lead.nombreEmpresa,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timestamp derecho: fecha + badge de estado
// ─────────────────────────────────────────────────────────────────────────────

class _LeadTimestamp extends StatefulWidget {
  final Lead lead;
  const _LeadTimestamp({required this.lead});

  @override
  State<_LeadTimestamp> createState() => _LeadTimestampState();
}

class _LeadTimestampState extends State<_LeadTimestamp> {
  late Duration _elapsed;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _updateElapsed());
    });
  }

  void _updateElapsed() {
    final fecha = DateFormatter.parseDate(widget.lead.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.lead.fechaHora.formatSinHoy(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ElapsedTimeUtils.formatHyM(_elapsed),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppIconsSocial.chipEstado(
          widget.lead.idEstado,
          label: widget.lead.estado,
        ),
      ],
    );
  }
}
