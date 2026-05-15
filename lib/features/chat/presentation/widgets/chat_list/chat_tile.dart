// lib/features/chats/presentation/widgets/chat_tile.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

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
      onTap: onTap,
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
                  backgroundColor: AvatarUtils.color(chat.nombreApe),
                  child: Text(
                    AvatarUtils.initials(chat.nombreApe),
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
                              chat.nombreApe,
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
                            chat.fechaHora.formatWhatsApp(),
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
                      _buildPreview(chat, mensajeSize, colorScheme),
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
    final preview = _previewText(chat);
    final hasIcon = preview.icon != null;

    return Row(
      children: [
        if (hasIcon) ...[
          Icon(
            preview.icon,
            size: mensajeSize + 1,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            preview.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: mensajeSize,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  _PreviewData _previewText(Chat chat) {
    final msg = chat.mensaje.toLowerCase();

    // El backend puede mandar el tipo en el mensaje cuando es archivo
    if (msg.startsWith('🎵') || msg.contains('[audio]')) {
      return _PreviewData(Icons.mic_rounded, 'Audio');
    }
    if (msg.startsWith('📷') ||
        msg.contains('[imagen]') ||
        msg.contains('[foto]')) {
      return _PreviewData(Icons.photo_rounded, 'Foto');
    }
    if (msg.startsWith('🎥') || msg.contains('[video]')) {
      return _PreviewData(Icons.videocam_rounded, 'Video');
    }
    if (msg.startsWith('📄') ||
        msg.contains('[archivo]') ||
        msg.contains('[documento]')) {
      return _PreviewData(Icons.insert_drive_file_rounded, 'Archivo');
    }

    // Texto normal
    return _PreviewData(null, chat.mensaje);
  }
}

class _PreviewData {
  final IconData? icon;
  final String text;
  const _PreviewData(this.icon, this.text);
}
