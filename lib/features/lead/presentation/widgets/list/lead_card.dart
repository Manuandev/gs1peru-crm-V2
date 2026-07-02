// lib/features/lead/presentation/widgets/list/lead_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadCard extends StatefulWidget {
  final Lead lead;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsAppTap;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onWhatsAppTap,
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
                      AppSpacing.xs,
                      AppSpacing.sm,
                      AppSpacing.xs,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 50%: avatar + nombre/oportunidad/empresa ──
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LeadAvatar(lead: l),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(child: _LeadClientInfo(lead: l)),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          // ── 50%: fecha/hace-X + estado arriba, acciones abajo ──
                          Expanded(
                            child: _LeadDateAndActions(
                              lead: l,
                              elapsed: _elapsed,
                              onWhatsAppTap: widget.onWhatsAppTap,
                              onVerDetalleTap: widget.onTap,
                            ),
                          ),
                        ],
                      ),
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

/// Avatar circular genérico y compacto — mismo estilo que en Conversaciones
/// (`ChatTile`): color por nombre + ícono de persona, sin iniciales ni badge.
class _LeadAvatar extends StatelessWidget {
  final Lead lead;

  const _LeadAvatar({required this.lead});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppSizing.avatarRadiusXs,
      backgroundColor: AvatarUtils.color(lead.nombreCompleto),
      child: Icon(
        AppIcons.user,
        size: AppSizing.iconSm,
        color: AppColors.textOnDark,
      ),
    );
  }
}

/// Nombre (negrita) + oportunidad (negrita, gris medio) + empresa (gris claro,
/// sin negrita) — mitad izquierda de la card.
class _LeadClientInfo extends StatelessWidget {
  final Lead lead;

  const _LeadClientInfo({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          lead.nombreCompleto,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: AppTextStyles.weightSemiBold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (lead.evento.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            lead.evento,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (lead.nombreEmpresa.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            lead.nombreEmpresa,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Fecha/hora + tiempo transcurrido junto al chip de estado (arriba) y
/// acciones WhatsApp/Ver detalle (abajo) — mitad derecha de la card.
class _LeadDateAndActions extends StatelessWidget {
  final Lead lead;
  final Duration elapsed;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onVerDetalleTap;

  const _LeadDateAndActions({
    required this.lead,
    required this.elapsed,
    this.onWhatsAppTap,
    this.onVerDetalleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lead.fechaHora.formatConDia(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Hace ${ElapsedTimeUtils.formatHoMoS(elapsed)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: ElapsedTimeUtils.colorFromElapsed(elapsed),
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: AppSocialUtils.chipEstado(
                lead.idEstadoEfectivo,
                label: lead.estadoEfectivo,
                fontSize: AppTextStyles.sizeXs,
              ),
            ),
          ],
        ),
        LeadCardActions(
          onWhatsAppTap: onWhatsAppTap,
          onVerDetalleTap: onVerDetalleTap,
        ),
      ],
    );
  }
}
