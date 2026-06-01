// lib/features/chats/presentation/widgets/chat_tile.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatefulWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late Duration _elapsed;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration.zero;
    _updateElapsed();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _updateElapsed());
    });
  }

  void _updateElapsed() {
    final fecha = DateFormatter.parseDate(widget.chat.fechaHora);
    if (fecha == null) return;
    _elapsed = DateTime.now().difference(fecha);
  }

  @override
  void didUpdateWidget(ChatTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.fechaHora != widget.chat.fechaHora) {
      _updateElapsed();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ─── Valores responsivos con ResponsiveHelper ─────────────────
    final avatarRadius = ResponsiveHelper.getValue<double>(
      context,
      mobile: 24,
      tablet: 26,
      desktop: 28,
    );
    final paddingH = ResponsiveHelper.getValue<double>(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
    final paddingV = ResponsiveHelper.getValue<double>(
      context,
      mobile: 10,
      tablet: 12,
      desktop: 14,
    );
    final nombreSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 15,
      tablet: 16,
      desktop: 17,
    );
    final mensajeSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 13,
      tablet: 14,
      desktop: 15,
    );
    final fechaSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 12,
      tablet: 12,
      desktop: 13,
    );

    // Divider alineado al texto (igual que WhatsApp)
    final dividerIndent = paddingH + (avatarRadius * 2) + 12;

    return InkWell(
      onTap: widget.onTap,
      // ignore: deprecated_member_use
      splashColor: colorScheme.primary.withOpacity(0.05),
      // ignore: deprecated_member_use
      highlightColor: colorScheme.primary.withOpacity(0.03),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingH,
              vertical: paddingV,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ─── Avatar ───────────────────────────────────────
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: AvatarUtils.color(widget.chat.nombreCompleto),
                  child: Text(
                    AvatarUtils.initials(widget.chat.nombreCompleto),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: avatarRadius * 0.58,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ─── Nombre + Mensaje + Fecha + Badge ─────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fila: Nombre | Fecha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.chat.nombreCompleto,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: nombreSize,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.chat.fechaHora.formatWhatsApp(),
                            style: TextStyle(
                              fontSize: fechaSize,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Fila: Mensaje | Badge
                      _buildPreview(widget.chat, mensajeSize, colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Divider alineado al texto ─────────────────────────
          Padding(
            padding: EdgeInsets.only(left: dividerIndent),
            child: Divider(
              height: 1,
              thickness: 0.4,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(Chat chat, double mensajeSize, ColorScheme colorScheme) {
    final preview = buildMessagePreview(chat);
    final hasIcon = preview.icon != null;

    return Row(
      children: [
        if (hasIcon) ...[
          Icon(preview.icon, size: mensajeSize + 1, color: preview.color),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            preview.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: mensajeSize,
              color: preview.color ?? Colors.grey.shade500,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        // Tiempo: solo si el cliente mando el mensaje
        if (chat.isEnviado) ...[
          const SizedBox(width: 6),
          Text(
            'Sin respuesta ${ElapsedTimeUtils.formatHoMoS(_elapsed)}',
            style: TextStyle(
              fontSize: mensajeSize - 1,
              color: ElapsedTimeUtils.colorFromElapsed(_elapsed),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        // Estado: solo si YO mandé el mensaje
        if (!chat.isEnviado) ...[
          const SizedBox(width: 4),
          MessageStatusIcon(estado: chat.estado, color: Colors.grey),
        ],
      ],
    );
  }
}
