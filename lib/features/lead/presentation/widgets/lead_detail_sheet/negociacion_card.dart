// lib/features/lead/presentation/widgets/lead_detail_sheet/negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionCard extends StatelessWidget {
  final NegociacionFake negociacion;
  final VoidCallback? onGenerarSolicitud;
  final VoidCallback? onEditarNegociacion;

  const NegociacionCard({
    super.key,
    required this.negociacion,
    this.onGenerarSolicitud,
    this.onEditarNegociacion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CuerpoCard(negociacion: negociacion),
          const Divider(color: AppColors.border, height: AppSpacing.lg),
          _BotonesAccion(
            onGenerarSolicitud: onGenerarSolicitud,
            onEditarNegociacion: onEditarNegociacion,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cuerpo: dos mitades horizontales al 50%
// ─────────────────────────────────────────────────────────────────────────────

class _CuerpoCard extends StatelessWidget {
  final NegociacionFake negociacion;
  const _CuerpoCard({required this.negociacion});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _MitadIzquierda(negociacion: negociacion)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _MitadDerecha(negociacion: negociacion)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mitad izquierda: ícono canal + info textual
// ─────────────────────────────────────────────────────────────────────────────

class _MitadIzquierda extends StatelessWidget {
  final NegociacionFake negociacion;
  const _MitadIzquierda({required this.negociacion});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarCanal(idCanal: negociacion.idCanal),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                negociacion.nombre,
                style: AppTextStyles.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                negociacion.empresa,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppIconsSocial.chipEstado(
                negociacion.idEstado,
                label: negociacion.estado,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Avatar circular con ícono del canal ─────────────────────────────────────

class _AvatarCanal extends StatelessWidget {
  final int idCanal;
  const _AvatarCanal({required this.idCanal});

  @override
  Widget build(BuildContext context) {
    final colorCanal = AppIconsSocial.colorCanal(idCanal);
    return Container(
      width: AppSizing.avatarSm,
      height: AppSizing.avatarSm,
      decoration: BoxDecoration(
        color: colorCanal.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIconsSocial.widgetCanal(
          idCanal,
          size: AppSizing.iconActionSm,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mitad derecha: canal, cantidad y última actualización
// ─────────────────────────────────────────────────────────────────────────────

class _MitadDerecha extends StatelessWidget {
  final NegociacionFake negociacion;
  const _MitadDerecha({required this.negociacion});

  @override
  Widget build(BuildContext context) {
    final colorCanal = AppIconsSocial.colorCanal(negociacion.idCanal);
    final nombreCanal = CanalHelper.get(negociacion.idCanal).nombre;
    final personas = negociacion.cantidad == 1
        ? '${negociacion.cantidad} persona'
        : '${negociacion.cantidad} personas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DatoColumna(
          etiqueta: 'Canal',
          valor: nombreCanal,
          colorValor: colorCanal,
        ),
        const SizedBox(height: AppSpacing.xs),
        _DatoColumna(
          etiqueta: 'Personas',
          valor: personas,
        ),
        const SizedBox(height: AppSpacing.xs),
        _DatoColumna(
          etiqueta: 'Actualizado',
          valor: negociacion.ultimaActualizacion,
          colorValor: AppColors.textSecondary,
        ),
      ],
    );
  }
}

// ─── Dato con etiqueta superior y valor inferior ──────────────────────────────

class _DatoColumna extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color? colorValor;

  const _DatoColumna({
    required this.etiqueta,
    required this.valor,
    this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          etiqueta,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          valor,
          style: AppTextStyles.labelMedium.copyWith(
            color: colorValor ?? AppColors.textPrimary,
            fontWeight: AppTextStyles.weightSemiBold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de botones de acción
// ─────────────────────────────────────────────────────────────────────────────

class _BotonesAccion extends StatelessWidget {
  final VoidCallback? onGenerarSolicitud;
  final VoidCallback? onEditarNegociacion;

  const _BotonesAccion({
    this.onGenerarSolicitud,
    this.onEditarNegociacion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSecondaryButton(
            text: 'Generar solicitud',
            onPressed: onGenerarSolicitud ?? () {},
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomPrimaryButton(
            text: 'Editar negociación',
            onPressed: onEditarNegociacion ?? () {},
          ),
        ),
      ],
    );
  }
}
