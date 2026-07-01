// lib/features/lead/presentation/widgets/list/lead_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadCard extends StatefulWidget {
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
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  Duration _elapsed = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _actualizarElapsed();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(_actualizarElapsed);
    });
  }

  void _actualizarElapsed() {
    final fecha = DateFormatter.parseDate(widget.lead.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _subtitulo {
    final l = widget.lead;
    final partes = [
      if (l.evento.isNotEmpty) l.evento,
      if (l.interes.isNotEmpty) l.interes,
      if (l.nombreEmpresa.isNotEmpty) l.nombreEmpresa,
    ];
    return partes.isEmpty ? '—' : partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lead;
    final colorBorde = AppSocialUtils.colorEstado(l.idEstadoEfectivo);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: AppSizing.cardBorderEstadoAncho, color: colorBorde),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Fila principal: avatar + info + timestamp ─────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LeadAvatar(lead: l),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          l.nombreCompleto,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: AppTextStyles.weightSemiBold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (l.idCanal > 0) ...[
                                        const SizedBox(width: AppSpacing.xs),
                                        _CanalPill(lead: l),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    _subtitulo,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _TimestampColumn(elapsed: _elapsed, lead: l),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // ── Acciones ───────────────────────────────────
                        LeadCardActions(
                          lead: l,
                          onWhatsAppTap: widget.onWhatsAppTap,
                          onVerDetalleTap: widget.onTap,
                          onChatTap: widget.onChatTap,
                          onStarTap: widget.onStarTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets privados ─────────────────────────────────────────────────────

/// Avatar circular con badge del canal en la esquina inferior derecha.
class _LeadAvatar extends StatelessWidget {
  final Lead lead;

  const _LeadAvatar({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: AppSizing.avatarRadiusMd,
          backgroundColor: AvatarUtils.color(lead.nombreCompleto),
          child: Text(
            AvatarUtils.initials(lead.nombreCompleto),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ),
        if (lead.idCanal > 0)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: AppSizing.avatarCanalBadge,
              height: AppSizing.avatarCanalBadge,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: AppSizing.canalBadgeBorder,
                ),
              ),
              child: Center(
                child: AppSocialUtils.widgetCanalById(
                  lead.idCanal,
                  size: AppSizing.iconCanalBadge,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pill pequeño con el nombre del canal, junto al nombre del lead.
class _CanalPill extends StatelessWidget {
  final Lead lead;

  const _CanalPill({required this.lead});

  @override
  Widget build(BuildContext context) {
    final color = AppSocialUtils.colorCanalById(lead.idCanal);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        lead.canal,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightMedium,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Columna derecha: fecha absoluta + tiempo relativo, y pill de estado.
class _TimestampColumn extends StatelessWidget {
  final Duration elapsed;
  final Lead lead;

  const _TimestampColumn({required this.elapsed, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          lead.fechaHora.formatConDia(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Hace ${ElapsedTimeUtils.formatHoMoS(elapsed)}',
          style: AppTextStyles.labelSmall.copyWith(
            color: ElapsedTimeUtils.colorFromElapsed(elapsed),
            fontWeight: AppTextStyles.weightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppSocialUtils.chipEstado(
          lead.idEstadoEfectivo,
          label: lead.estadoEfectivo,
          fontSize: AppTextStyles.sizeXs,
        ),
      ],
    );
  }
}
