// lib/features/cobranza/presentation/widgets/lista/cobranza_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaCard extends StatelessWidget {
  final Cobranza cobranza;
  final VoidCallback? onVerTap;
  final VoidCallback? onWhatsAppTap;

  const CobranzaCard({
    super.key,
    required this.cobranza,
    this.onVerTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila superior: avatar + nombre + estado + acciones ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CobranzaAvatar(cobranza: cobranza),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _CobranzaNombre(cobranza: cobranza)),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _EstadoBadge(cobranza: cobranza),
                  const SizedBox(height: AppSpacing.sm),
                  _BotonWhatsApp(onTap: onWhatsAppTap),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Fila de datos: monto / ejecutivo / condición ────────
          _CobranzaDatos(cobranza: cobranza),

          const SizedBox(height: AppSpacing.xs),

          // ── Fecha + botón Ver ───────────────────────────────────
          _CobranzaFechaVer(cobranza: cobranza, onVerTap: onVerTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar circular con iniciales
// ─────────────────────────────────────────────────────────────────────────────

class _CobranzaAvatar extends StatelessWidget {
  final Cobranza cobranza;
  const _CobranzaAvatar({required this.cobranza});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppSizing.avatarRadiusMd,
      backgroundColor: AvatarUtils.color(cobranza.nombreCompleto),
      child: Text(
        AvatarUtils.initials(cobranza.nombreCompleto),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnDark,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nombre + evento (subtítulo)
// ─────────────────────────────────────────────────────────────────────────────

class _CobranzaNombre extends StatelessWidget {
  final Cobranza cobranza;
  const _CobranzaNombre({required this.cobranza});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cobranza.nombreCompleto,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: AppTextStyles.weightSemiBold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          cobranza.evento,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge de estado (Facturar / Pend. documento / Pend. pago / Cancelado)
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final Cobranza cobranza;
  const _EstadoBadge({required this.cobranza});

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(cobranza.idEstado);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizing.radiusXl),
      ),
      child: Text(
        cobranza.estado,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textOnDark,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }

  Color _colorEstado(String idEstado) {
    switch (idEstado) {
      case 'F':
        return AppColors.primary;
      case 'PD':
        return AppColors.warning;
      case 'PP':
        return AppColors.secondary;
      case 'CA':
        return AppColors.success;
      default:
        return AppColors.textDisabled;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón de WhatsApp
// ─────────────────────────────────────────────────────────────────────────────

class _BotonWhatsApp extends StatelessWidget {
  final VoidCallback? onTap;
  const _BotonWhatsApp({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppSizing.buttonHeightSmall,
        height: AppSizing.buttonHeightSmall,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppIconsSocial.colorCanal(1).withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: FaIcon(
          AppIconsSocial.whatsapp,
          size: AppSizing.iconSm,
          color: AppIconsSocial.colorCanal(1),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de datos: Monto total / Ejecutivo / Condición
// ─────────────────────────────────────────────────────────────────────────────

class _CobranzaDatos extends StatelessWidget {
  final Cobranza cobranza;
  const _CobranzaDatos({required this.cobranza});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DatoItem(
          label: 'Monto total',
          valor: 'S/ ${cobranza.montoTotal.toStringAsFixed(2)}',
          valorColor: AppColors.primary,
          valorBold: true,
        ),
        const SizedBox(width: AppSpacing.sm),
        _DatoItem(label: 'Ejecutivo', valor: cobranza.ejecutivo),
        const SizedBox(width: AppSpacing.sm),
        _DatoItem(label: 'Condición', valor: cobranza.condicion),
      ],
    );
  }
}

class _DatoItem extends StatelessWidget {
  final String label;
  final String valor;
  final Color? valorColor;
  final bool valorBold;

  const _DatoItem({
    required this.label,
    required this.valor,
    this.valorColor,
    this.valorBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            valor,
            style: AppTextStyles.bodySmall.copyWith(
              color: valorColor ?? AppColors.textPrimary,
              fontWeight: valorBold
                  ? AppTextStyles.weightSemiBold
                  : AppTextStyles.weightRegular,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fecha de cobranza / vencimiento + botón Ver
// ─────────────────────────────────────────────────────────────────────────────

class _CobranzaFechaVer extends StatelessWidget {
  final Cobranza cobranza;
  final VoidCallback? onVerTap;

  const _CobranzaFechaVer({required this.cobranza, this.onVerTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          AppIcons.calendar,
          size: AppSizing.iconSm,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: _textoFecha()),
        _BotonVer(onTap: onVerTap),
      ],
    );
  }

  Widget _textoFecha() {
    final tieneVencimiento = cobranza.fechaVencimiento != null;
    final dias = cobranza.diasVencimiento;
    final esUrgente = dias != null && dias <= 7;

    if (!tieneVencimiento) {
      return Text(
        cobranza.fecha,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Row(
      children: [
        Text(
          'Vence: ${cobranza.fechaVencimiento}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        if (dias != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($dias días)',
            style: AppTextStyles.bodySmall.copyWith(
              color: esUrgente ? AppColors.warning : AppColors.textSecondary,
              fontWeight: esUrgente
                  ? AppTextStyles.weightSemiBold
                  : AppTextStyles.weightRegular,
            ),
          ),
        ],
      ],
    );
  }
}

class _BotonVer extends StatelessWidget {
  final VoidCallback? onTap;
  const _BotonVer({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
        child: Text(
          'Ver',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: AppTextStyles.weightSemiBold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
