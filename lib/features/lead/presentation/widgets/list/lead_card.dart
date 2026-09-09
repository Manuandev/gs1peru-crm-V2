// lib/features/lead/presentation/widgets/list/lead_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadCard extends StatefulWidget {
  final ContactoNegociacion lead;
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _actualizarElapsed();
    _reiniciarTimer();
  }

  @override
  void didUpdateWidget(covariant LeadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // LeadListBloc parchea `lead` en memoria cuando LeadUpdateNotifier avisa
    // un cambio — sin esto, "Hace X" se quedaba con el valor viejo hasta el
    // próximo tick del Timer (hasta 1 minuto de espera).
    if (oldWidget.lead.negociacion.fechaHoraInteraccion !=
        widget.lead.negociacion.fechaHoraInteraccion) {
      _actualizarElapsed();
      _reiniciarTimer();
    }
  }

  // Tiquea cada segundo mientras el lead sea reciente (< 1 min) para que se
  // vea "correr" en tiempo real justo después de editar; pasado el minuto,
  // vuelve a cada minuto — no tiene sentido redibujar cada segundo una
  // tarjeta de hace días.
  void _reiniciarTimer() {
    _timer?.cancel();
    final eraReciente = _elapsed.inMinutes < 1;
    _timer = Timer.periodic(
      eraReciente ? const Duration(seconds: 1) : const Duration(minutes: 1),
      (_) {
        if (!mounted) return;
        final seguiaReciente = _elapsed.inMinutes < 1;
        setState(_actualizarElapsed);
        if (seguiaReciente && _elapsed.inMinutes >= 1) {
          _reiniciarTimer();
        }
      },
    );
  }

  void _actualizarElapsed() {
    final fecha = DateFormatter.parseDate(
      widget.lead.negociacion.fechaHoraInteraccion,
    );
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lead;
    // Task 'LSP' trae con idLead 0 y sin estado a los contactos sin negociación
    // ACTIVA (el SP excluye estado '04'). Dos sub-casos, según totalLeads
    // (CL.CT_LEADS = todas las negociaciones del contacto, cerradas incluidas):
    //   totalLeads == 0 → nunca tuvo negociación   → "Sin negociación"
    //   totalLeads  > 0 → todas cerradas/perdidas  → "Sin negociación activa"
    final sinNegociacionActiva = l.negociacion.idLead == 0;
    final soloCerradas = sinNegociacionActiva && l.totalLeads > 0;
    final colorBorde = soloCerradas
        ? AppSocialUtils.colorEstado('04')
        : sinNegociacionActiva
        ? AppColors.border
        : AppSocialUtils.colorEstado(l.negociacion.idEstadoEfectivo);

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
  final ContactoNegociacion lead;

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

/// Nombre (negrita) → badge "N negociaciones" → oportunidad (negrita, gris
/// medio) → empresa (gris claro, sin negrita), uno debajo del otro — mitad
/// izquierda de la card.
class _LeadClientInfo extends StatelessWidget {
  final ContactoNegociacion lead;

  const _LeadClientInfo({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Nombre en su propia línea — el badge de negociaciones bajó abajo
        // (antes iba al lado y le comía espacio al nombre).
        Text(
          lead.nombreCompleto,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: AppTextStyles.weightSemiBold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // totalLeads en 0 → el backend todavía no manda CL.CT_LEADS
        // (SP viejo desplegado); no mostramos el badge para no mentir.
        if (lead.totalLeads > 0) ...[
          const SizedBox(height: AppSpacing.xxs),
          _CasosBadge(count: lead.totalLeads),
        ],
        if (lead.negociacion.nombreOportunidad.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            lead.negociacion.nombreOportunidad.aTitulo,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (lead.contacto.nombreEmpresa.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            lead.contacto.nombreEmpresa.aTitulo,
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
  final ContactoNegociacion lead;
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
    final vencido = _tiempoChatAbiertoVencido();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.tap,
                  size: AppSizing.iconInline,
                  color: ElapsedTimeUtils.colorFromElapsed(elapsed),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  ElapsedTimeUtils.formatDoHoMoS(elapsed),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: ElapsedTimeUtils.colorFromElapsed(elapsed),
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: lead.negociacion.idLead == 0
                  ? _SinNegociacionChip(soloCerradas: lead.totalLeads > 0)
                  : AppSocialUtils.chipEstado(
                      lead.negociacion.idEstadoEfectivo,
                      label: lead.negociacion.estadoEfectivo,
                      fontSize: AppTextStyles.sizeXs,
                    ),
            ),
          ],
        ),
        LeadCardActions(
          onWhatsAppTap: onWhatsAppTap,
          onVerDetalleTap: onVerDetalleTap,
          mostrarWhatsApp: lead.numero.idChatCab > 0,
          whatsAppVencido: vencido,
        ),
      ],
    );
  }

  // Ventana desde el primer mensaje del cliente (Numero.fechaPrimerMensajeCliente)
  // durante la cual el botón de WhatsApp se muestra verde — mismo cálculo y
  // misma config (TDE) que ChatInputBar._tiempoChatAbiertoVencido() en `chat/`,
  // pero aquí sobre el número/lead de la lista, no sobre un chat abierto.
  bool _tiempoChatAbiertoVencido() {
    final fechaPrimerMensaje = DateFormatter.parseDate(
      lead.numero.fechaPrimerMensajeCliente,
    );
    if (fechaPrimerMensaje == null) return false;

    final transcurrido = DateTime.now().difference(fechaPrimerMensaje);
    final limite = ConfiguracionService().tiempoChatAbierto;
    return transcurrido.inMinutes >= limite * 60;
  }
}

/// Chip que reemplaza al de estado cuando el contacto no tiene negociación
/// ACTIVA (`idLead == 0`). [soloCerradas] distingue:
///   false → nunca tuvo negociación        → "Sin negociación" (neutro)
///   true  → tuvo, todas cerradas/perdidas  → "Sin negociación activa" (tono Cerrado)
class _SinNegociacionChip extends StatelessWidget {
  final bool soloCerradas;

  const _SinNegociacionChip({required this.soloCerradas});

  @override
  Widget build(BuildContext context) {
    final color = soloCerradas
        ? AppSocialUtils.colorEstado('04')
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: soloCerradas
            ? color.withValues(alpha: 0.12)
            : AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        soloCerradas ? 'Sin negociación activa' : 'Sin negociación',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
          fontSize: AppTextStyles.sizeXs,
        ),
      ),
    );
  }
}

/// Badge "N negociaciones" — cuántas negociaciones tiene el contacto
/// (CL.CT_LEADS). Debajo del nombre, en `_LeadClientInfo`.
class _CasosBadge extends StatelessWidget {
  final int count;

  const _CasosBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        count == 1 ? '1 negociación' : '$count negociaciones',
        style: AppTextStyles.labelVerySmall8.copyWith(
          color: AppColors.textSecondary,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
