// lib/features/chats/presentation/widgets/chat_tile.dart

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  // ─── Fecha estilo WhatsApp ─────────────────────────────────────
  // Hoy     → "20:24"
  // Ayer    → "Ayer"
  // <7 días → "miércoles"
  // Resto   → "26/03/2025"
  String _formatFecha(String fechaHora) {
    if (fechaHora.isEmpty) return '';
    try {
      final fecha = DateTime.parse(fechaHora);
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
      final diferencia = hoy.difference(diaFecha).inDays;

      if (diferencia == 0) {
        return fechaHora.formatDate(AppDateFormat.hourMinute);
      }
      if (diferencia == 1) return 'Ayer';

      if (diferencia < 7) {
        return fechaHora.formatDate(AppDateFormat.weekdayOnly);
      }

      return fechaHora.formatDate(AppDateFormat.shortDate);
    } catch (_) {
      return '';
    }
  }

  // ─── Iniciales del nombre ──────────────────────────────────────
  String _initials(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  // ─── Color dinámico por nombre ────────────────────────────────
  Color _avatarColor(String nombre) {
    const colores = [
      Color(0xFF1976D2),
      Color(0xFF388E3C),
      Color(0xFFD32F2F),
      Color(0xFF7B1FA2),
      Color(0xFFF57C00),
      Color(0xFF0097A7),
      Color(0xFF5D4037),
      Color(0xFF455A64),
    ];
    final index = nombre.isNotEmpty ? nombre.codeUnitAt(0) % colores.length : 0;
    return colores[index];
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
                  backgroundColor: _avatarColor(chat.nombreApe),
                  child: Text(
                    _initials(chat.nombreApe),
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
                            _formatFecha(chat.fechaHora),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.mensaje,
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
                      ),
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
}
