// lib/features/chat/presentation/widgets/chat_list/chat_tile.dart

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
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
            // ── Fila principal ────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusSm,
                  backgroundColor: AvatarUtils.color(chat.nombreCompleto),
                  child: Icon(
                    AppIcons.user,
                    size: AppSizing.iconMd,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _InfoChat(chat: chat)),
                const SizedBox(width: AppSpacing.sm),
                _InfoDerecha(chat: chat),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chat.idEstado.isEmpty
                        ? const _ChipSinEstado()
                        : AppSocialUtils.chipEstado(
                            chat.idEstadoEfectivo,
                            label: chat.descEstadoEfectiva,
                          ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      chat.fechaHora.formatDate(AppDateFormat.hourMinute),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1, thickness: 0.5, color: AppColors.border),
            const SizedBox(height: AppSpacing.xxs),

            // ── Fila de acciones ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (chat.isDerivadoIA)
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        _ChipInfo(
                          icon: AppIcons.lightning,
                          label: 'Derivado por IA',
                          bgColor: AppColors.datoSubestadobg,
                          fgColor: AppColors.datoSubestadoFg,
                        ),
                        _ChipInfo(
                          icon: AppIcons.ia,
                          label:
                              'Bot atendió ${chat.cantidadMensajesIA} mensajes',
                          bgColor: AppColors.datoEstadoBg,
                          fgColor: AppColors.datoEstadoFg,
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: AppSizing.botonVerChat,
                      child: CustomOutlinedButton(
                        text: 'Ver chat',
                        onPressed: onTap,
                        textStyle: AppTextStyles.labelMedium,
                        height: AppSizing.buttonHeightCompact,
                        borderColor: AppColors.border,
                        borderWidth: AppSizing.hairline,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppSizing.hairline,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => LauncherUtils.abrirTelefono(
                          '${chat.prefijoPais} ${chat.numero}',
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSizing.radiusCircular,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            AppIcons.phone,
                            size: AppSizing.iconActionSm,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Info central: nombre + chip canal, oportunidad, empresa, mensaje, chips IA
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChat extends StatelessWidget {
  final Chat chat;
  const _InfoChat({required this.chat});

  @override
  Widget build(BuildContext context) {
    final preview = buildClientMessagePreview(chat);
    final tieneCanal = chat.idCanal > 0;
    final nombre = chat.nombreCompleto.length > AppConstants.maxCharsNombreChat
        ? '${chat.nombreCompleto.substring(0, AppConstants.maxCharsNombreChat)}...'
        : chat.nombreCompleto;
    final mensajeRaw = preview.label;
    final mensajeTrunc = mensajeRaw.length > AppConstants.maxCharsMensajeChat
        ? '${mensajeRaw.substring(0, AppConstants.maxCharsMensajeChat)}...'
        : mensajeRaw;
    final mensaje = mensajeTrunc.length > AppConstants.maxCharsLineaMensaje
        ? '${mensajeTrunc.substring(0, AppConstants.maxCharsLineaMensaje)}\n${mensajeTrunc.substring(AppConstants.maxCharsLineaMensaje)}'
        : mensajeTrunc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre + chip canal
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                nombre,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (tieneCanal) ...[
              const SizedBox(width: AppSpacing.xs),
              AppSocialUtils.widgetCanalById(
                chat.idCanal,
                size: AppSizing.iconSm,
              ),
            ],
          ],
        ),

        // Oportunidad
        if (chat.nombreOportunidad.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.nombreOportunidad,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: AppTextStyles.weightBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Empresa
        if (chat.nombreEmpresa.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.nombreEmpresa,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: AppSpacing.xxs),

        // Preview del último mensaje (natural ellipsis)
        Row(
          children: [
            if (preview.icon != null) ...[
              Icon(
                preview.icon,
                size: AppSizing.iconCanalInfo,
                color: preview.color ?? AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Expanded(
              child: Text(
                mensaje,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: preview.color ?? AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info derecha: tiempo sin respuesta + badge estado + hora del último mensaje
// ─────────────────────────────────────────────────────────────────────────────

class _InfoDerecha extends StatefulWidget {
  final Chat chat;
  const _InfoDerecha({required this.chat});

  @override
  State<_InfoDerecha> createState() => _InfoDerechaState();
}

class _InfoDerechaState extends State<_InfoDerecha> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Chat get chat => widget.chat;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();

    // Tiempo desde el primer mensaje del cliente
    final fechaPrimerMensaje = DateFormatter.parseDate(
      chat.fcPrimerMensajeCliente,
    );
    final elapsedPrimero = fechaPrimerMensaje != null
        ? ahora.difference(fechaPrimerMensaje)
        : null;

    // "Sin respuesta" — solo visible si el cliente mandó el último mensaje
    final clienteEsUltimo = chat.direccionMensaje == 'CLI';
    final fechaUltimoMensaje = DateFormatter.parseDate(chat.fechaHora);
    final elapsedSinRespuesta = fechaUltimoMensaje != null
        ? ahora.difference(fechaUltimoMensaje)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (elapsedPrimero != null)
          Text(
            ElapsedTimeUtils.formatHyM(elapsedPrimero),
            style: AppTextStyles.labelMedium.copyWith(
              color: ElapsedTimeUtils.colorFromElapsed(elapsedPrimero),
              fontWeight: AppTextStyles.weightBold,
            ),
            textAlign: TextAlign.center,
          ),
        if (clienteEsUltimo && elapsedSinRespuesta != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'sin respuesta',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            ElapsedTimeUtils.formatHoMoS(elapsedSinRespuesta),
            style: AppTextStyles.labelMedium.copyWith(
              color: ElapsedTimeUtils.colorFromElapsed(elapsedSinRespuesta),
              fontWeight: AppTextStyles.weightBold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip informativo pequeño: ícono + texto con fondo de color suave
// Usado para "Derivado por IA" y "Bot atendió N mensajes"
// ─────────────────────────────────────────────────────────────────────────────

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizing.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizing.iconSm, color: fgColor),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.labelVerySmall8.copyWith(
              color: fgColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip "Sin estado" — reemplaza el chip de etapa cuando el número no tiene
// lead asociado (chat.idEstado vacío), evitando el círculo vacío sin texto.
// ─────────────────────────────────────────────────────────────────────────────

class _ChipSinEstado extends StatelessWidget {
  const _ChipSinEstado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.sinEstadoBg,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        'Sin estado',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.sinEstadoFg,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
