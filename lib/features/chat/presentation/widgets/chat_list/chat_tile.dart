// lib/features/chat/presentation/widgets/chat_list/chat_tile.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatefulWidget {
  final Chat chat;
  final int mensajesNoLeidos;
  final VoidCallback? onTap;
  final VoidCallback? onResponderTap;
  final VoidCallback? onEtiquetarTap;

  const ChatTile({
    super.key,
    required this.chat,
    this.mensajesNoLeidos = 0,
    this.onTap,
    this.onResponderTap,
    this.onEtiquetarTap,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _startTimer();
  }

  void _updateElapsed() {
    final fecha = DateFormatter.parseDate(widget.chat.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  void _startTimer() {
    _timer?.cancel();
    if (_elapsed.inSeconds < 60) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _updateElapsed());
        if (_elapsed.inSeconds >= 60) _startTimer();
      });
    } else {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        setState(() => _updateElapsed());
      });
    }
  }

  @override
  void didUpdateWidget(ChatTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.mensaje != widget.chat.mensaje) {
      setState(() => _updateElapsed());
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.sm,
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
            // ── Fila principal ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AvatarConCanal(chat: widget.chat),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _InfoChat(chat: widget.chat)),
                const SizedBox(width: AppSpacing.sm),
                _ColumnaFecha(chat: widget.chat, elapsed: _elapsed),
                const SizedBox(width: AppSpacing.xxs),
                const Icon(
                  AppIcons.chevronRight,
                  size: AppSizing.iconSm,
                  color: AppColors.textDisabled,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            // const Divider(height: 1, thickness: 0.5, color: AppColors.border),
            // const SizedBox(height: AppSpacing.xs),

            // // ── Barra de acciones ────────────────────────────────────────
            // _BarraAcciones(
            //   chat: widget.chat,
            //   mensajesNoLeidos: widget.mensajesNoLeidos,
            //   onResponderTap: widget.onResponderTap,
            //   onEtiquetarTap: widget.onEtiquetarTap,
            // ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar con badge del canal en esquina inferior derecha
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarConCanal extends StatelessWidget {
  final Chat chat;

  const _AvatarConCanal({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: AppSizing.avatarRadiusMd,
          backgroundColor: AvatarUtils.color(chat.nombreCompleto),
          child: Text(
            AvatarUtils.initials(chat.nombreCompleto),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (chat.idCanal > 0)
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: AppSizing.avatarCanalBadge,
              height: AppSizing.avatarCanalBadge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border,
                  width: AppSizing.canalBadgeBorder,
                ),
              ),
              alignment: Alignment.center,
              child: AppIconsSocial.widgetCanal(
                chat.idCanal,
                size: AppSizing.iconCanalBadge,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info central: nombre + canal, empresa, último mensaje
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChat extends StatelessWidget {
  final Chat chat;

  const _InfoChat({required this.chat});

  @override
  Widget build(BuildContext context) {
    final preview = buildMessagePreview(chat);
    final canalNombre = CanalHelper.get(chat.idCanal).nombre;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre + ícono de canal + nombre del canal
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                chat.nombreCompleto,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (chat.idCanal > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              AppIconsSocial.widgetCanal(
                chat.idCanal,
                size: AppSizing.iconCanalInfo,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                canalNombre,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        if (chat.nombreEmpresa.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            chat.nombreEmpresa,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.xxs),
        // Último mensaje con ícono de tipo si aplica
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
                preview.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
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
// Columna derecha: hora + chip "sin respuesta" o estado de entrega + chip etapa
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnaFecha extends StatelessWidget {
  final Chat chat;
  final Duration elapsed;

  const _ColumnaFecha({required this.chat, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final colorElapsed = ElapsedTimeUtils.colorFromElapsed(elapsed);
    final textoElapsed = ElapsedTimeUtils.formatHyM(elapsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Hora
        Text(
          chat.fechaHora.formatSinHoy(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        // Sin respuesta (solo cuando el cliente envió el último mensaje)
        if (chat.isEnviado)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colorElapsed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusXs),
            ),
            child: Text(
              'Sin respuesta $textoElapsed',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorElapsed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxs),

        // Chip de etapa del lead
        // AppIconsSocial.chipEstado(
        //   chat.idEstado,
        //   label: chat.estado,
        // ),
        MessageStatusIcon(estado: chat.estado, color: Colors.grey),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Barra de acciones: Responder | Etiquetar | ... + badge de mensajes no leídos
// ─────────────────────────────────────────────────────────────────────────────

class _BarraAcciones extends StatelessWidget {
  final Chat chat;
  final int mensajesNoLeidos;
  final VoidCallback? onResponderTap;
  final VoidCallback? onEtiquetarTap;

  const _BarraAcciones({
    required this.chat,
    required this.mensajesNoLeidos,
    this.onResponderTap,
    this.onEtiquetarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BotonAccion(
          icono: AppIconsSocial.widgetCanal(
            chat.idCanal,
            size: AppSizing.iconSm,
          ),
          etiqueta: 'Responder',
          onTap: onResponderTap,
        ),
        const _SeparadorAccion(),
        _BotonAccion(
          icono: const Icon(
            AppIcons.interes,
            size: AppSizing.iconSm,
            color: AppColors.textSecondary,
          ),
          etiqueta: 'Etiquetar',
          onTap: onEtiquetarTap,
        ),
        const _SeparadorAccion(),
        const _BotonAccion(
          icono: Icon(
            AppIcons.moreHorizontal,
            size: AppSizing.iconSm,
            color: AppColors.textSecondary,
          ),
          etiqueta: '...',
        ),
        const Spacer(),
        if (mensajesNoLeidos > 0)
          Container(
            constraints: const BoxConstraints(
              minWidth: AppSizing.mensajesBadgeSize,
              minHeight: AppSizing.mensajesBadgeSize,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              mensajesNoLeidos > 99 ? '99+' : '$mensajesNoLeidos',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final Widget icono;
  final String etiqueta;
  final VoidCallback? onTap;

  const _BotonAccion({required this.icono, required this.etiqueta, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icono,
          const SizedBox(width: AppSpacing.xxs),
          Text(
            etiqueta,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeparadorAccion extends StatelessWidget {
  const _SeparadorAccion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        '|',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.border),
      ),
    );
  }
}
