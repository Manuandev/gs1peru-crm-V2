// lib/features/lead/presentation/widgets/list/lead_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadCard extends StatefulWidget {
  final Lead lead;
  final bool modoCompacto;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onStarTap;

  const LeadCard({
    super.key,
    required this.lead,
    this.modoCompacto = false,
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

  @override
  Widget build(BuildContext context) {
    return widget.modoCompacto ? _buildCompacta() : _buildDetallada();
  }

  // ── Contenedor base compartido ──────────────────────────────────────────────

  Widget _buildBase({required Widget content}) {
    final colorBorde = AppIconsSocial.colorEstado(widget.lead.idEstado);
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
                Container(
                  width: AppSizing.cardBorderEstadoAncho,
                  color: colorBorde,
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Vista detallada ─────────────────────────────────────────────────────────

  Widget _buildDetallada() {
    return _buildBase(
      content: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila principal: avatar + info + timestamp ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadAvatar(lead: widget.lead),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lead.nombreCompleto,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      _LeadEstadoRow(lead: widget.lead),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _TimestampDetallada(elapsed: _elapsed, lead: widget.lead),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // ── Subtítulo ─────────────────────────────────────────────
            Text(
              _subtitulo,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.xs),

            // ── Acciones ──────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: LeadCardActions(
                lead: widget.lead,
                onWhatsAppTap: widget.onWhatsAppTap,
                onChatTap: widget.onChatTap,
                onStarTap: widget.onStarTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vista compacta ──────────────────────────────────────────────────────────

  Widget _buildCompacta() {
    final colorElapsed = ElapsedTimeUtils.colorFromElapsed(_elapsed);
    final colorEstado = AppIconsSocial.colorEstado(widget.lead.idEstado);
    return _buildBase(
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ────────────────────────────────────────────────
            _LeadAvatar(lead: widget.lead),
            const SizedBox(width: AppSpacing.sm),

            // ── Info central ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lead.nombreCompleto,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  _LeadEstadoRow(lead: widget.lead),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _subtitulo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // ── Columna derecha: tiempo + estado | iconos ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ElapsedTimeUtils.formatHyM(_elapsed),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorElapsed,
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.lead.estado,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xs),
                Column(
                  children: [
                    if (widget.lead.ibChat) ...[
                      _IconoCompacto(
                        icon: AppIcons.chat,
                        color: AppColors.primary,
                        onTap: widget.onChatTap,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                    ],
                    _IconoCompacto(
                      icon: widget.lead.isFavorito
                          ? AppIcons.starFilled
                          : AppIcons.star,
                      color: widget.lead.isFavorito
                          ? AppColors.favorito
                          : AppColors.textDisabled,
                      onTap: widget.onStarTap,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _subtitulo {
    final partes = [
      if (widget.lead.evento.isNotEmpty) widget.lead.evento,
      if (widget.lead.interes.isNotEmpty) widget.lead.interes,
      if (widget.lead.nombreEmpresa.isNotEmpty) widget.lead.nombreEmpresa,
    ];
    return partes.isEmpty ? '—' : partes.join(' · ');
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
                child: AppIconsSocial.widgetCanal(
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

/// Fila: ● Estado  ·  [canal icon]  [canal name]
class _LeadEstadoRow extends StatelessWidget {
  final Lead lead;

  const _LeadEstadoRow({required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppIconsSocial.colorEstado(lead.idEstado);
    return Row(
      children: [
        Icon(AppIcons.circuloRelleno, size: AppSizing.iconXxs, color: colorEstado),
        const SizedBox(width: AppSpacing.xs),
        Text(
          lead.estado,
          style: AppTextStyles.labelSmall.copyWith(color: colorEstado),
        ),
        if (lead.idCanal > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          AppIconsSocial.widgetCanal(lead.idCanal, size: AppSizing.iconCanalInfo),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              lead.canal,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// Columna derecha de la tarjeta detallada: tiempo en color + fecha en gris.
class _TimestampDetallada extends StatelessWidget {
  final Duration elapsed;
  final Lead lead;

  const _TimestampDetallada({required this.elapsed, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ElapsedTimeUtils.formatHyM(elapsed),
          style: AppTextStyles.bodySmall.copyWith(
            color: ElapsedTimeUtils.colorFromElapsed(elapsed),
            fontWeight: AppTextStyles.weightSemiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          lead.fechaHora.formatSinHoy(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Ícono táctil sin fondo — para la columna derecha del modo compacto.
class _IconoCompacto extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconoCompacto({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: AppSizing.iconSm, color: color),
    );
  }
}
