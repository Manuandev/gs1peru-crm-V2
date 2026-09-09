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
                      chat.fechaHora.formatConDia(),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (chat.isDerivadoIA)
                        _ChipInfo(
                          icon: AppIcons.sparkle,
                          bgColor: AppColors.datoSubestadobg,
                          fgColor: AppColors.datoSubestadoFg,
                          label: null,
                        ),
                      if (chat.isDerivadoIA)
                        _ChipInfo(
                          icon: AppIcons.ia,
                          // Solo ícono del bot + cantidad de mensajes (pedido
                          // de negocio) — sin el texto "Bot atendió N mensajes".
                          label: '${chat.cantidadMensajesIA}',
                          bgColor: AppColors.datoEstadoBg,
                          fgColor: AppColors.datoEstadoFg,
                        ),
                      // Tiempo "sin respuesta" / "esperando respuesta" como
                      // etiqueta acá (antes ocupaba ancho en la fila principal
                      // y recortaba el nombre/número).
                      _ChipSinRespuesta(chat: chat),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
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
    // Nombre/número completos, sin recorte manual — el bloque de la derecha
    // ("sin respuesta"/"esperando respuesta") se movió a una etiqueta abajo,
    // así que ya hay ancho para mostrarlo entero (hasta 2 líneas).
    final nombre = chat.nombreCompleto;
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
                  fontWeight: AppTextStyles.weightBold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
            chat.nombreOportunidad.aTitulo,
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
            chat.nombreEmpresa.aTitulo,
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
// Info derecha: solo el tiempo desde el PRIMER mensaje del cliente (el de
// "sin respuesta" se movió a la etiqueta _ChipSinRespuesta de la fila de abajo)
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
    // Tiempo desde el primer mensaje del cliente — "eso se entiende" (pedido
    // de negocio), se queda acá. El de "sin respuesta" ahora es _ChipSinRespuesta.
    final fechaPrimerMensaje = DateFormatter.parseDate(
      chat.fcPrimerMensajeCliente,
    );
    if (fechaPrimerMensaje == null) return const SizedBox.shrink();
    final elapsedPrimero = DateTime.now().difference(fechaPrimerMensaje);

    return Text(
      ElapsedTimeUtils.formatDoHoMoS(elapsedPrimero),
      style: AppTextStyles.labelMedium.copyWith(
        color: ElapsedTimeUtils.colorFromElapsed(elapsedPrimero),
        fontWeight: AppTextStyles.weightBold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etiqueta "Xd sin respuesta" / "Xh esperando respuesta" — al lado de los chips
// del bot. Sale siempre que haya un último mensaje. StatefulWidget con ticker
// de 1s para que el tiempo avance solo, igual que _InfoDerecha.
// ─────────────────────────────────────────────────────────────────────────────

class _ChipSinRespuesta extends StatefulWidget {
  final Chat chat;
  const _ChipSinRespuesta({required this.chat});

  @override
  State<_ChipSinRespuesta> createState() => _ChipSinRespuestaState();
}

class _ChipSinRespuestaState extends State<_ChipSinRespuesta> {
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

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final fechaUltimoMensaje = DateFormatter.parseDate(chat.fechaHora);
    if (fechaUltimoMensaje == null) return const SizedBox.shrink();

    final elapsed = DateTime.now().difference(fechaUltimoMensaje);
    // Cliente mandó el último mensaje → falta que respondamos ("sin respuesta").
    // Nosotros/el bot mandamos el último → esperamos al cliente.
    final clienteEsUltimo = chat.direccionMensaje == 'CLI';

    return _ChipInfo(
      icon: AppIcons.accessTime,
      label:
          '${ElapsedTimeUtils.formatDoHoMoS(elapsed)} '
          '${clienteEsUltimo ? 'sin respuesta' : 'esperando respuesta'}',
      // Fondo blanco + borde suave (pedido de negocio).
      bgColor: AppColors.surface,
      borderColor: AppColors.border,
      fgColor: ElapsedTimeUtils.colorFromElapsed(elapsed),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip informativo pequeño: ícono + texto con fondo de color suave
// Usado para "Derivado por IA" (solo ícono) y el ícono del bot + N mensajes
// ─────────────────────────────────────────────────────────────────────────────

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color bgColor;
  final Color fgColor;
  // Borde opcional — los chips de IA no lo llevan; la etiqueta de "sin
  // respuesta" sí (fondo blanco + borde suave).
  final Color? borderColor;

  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
    this.borderColor,
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
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: AppSizing.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizing.iconSm, color: fgColor),
          if (label != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label!,
              style: AppTextStyles.labelVerySmall8.copyWith(
                color: fgColor,
                height: 1,
              ),
            ),
          ],
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
