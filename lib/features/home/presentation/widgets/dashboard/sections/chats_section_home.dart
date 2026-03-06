

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/home/index_home.dart';

import 'package:flutter/material.dart';

class ChatsSection extends StatelessWidget {
  final List<Chat> chats;
  const ChatsSection({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER DE LA SECCIÓN ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nuevos chats', style: AppTextStyles.titleMedium),
                if (chats.isNotEmpty)
                  Text(
                    '${chats.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const Divider(),

            // ── LISTA O VACÍO ─────────────────────────────────
            if (chats.isEmpty)
              const AppEmptyView(message: 'No tienes chats pendientes')
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final visibleItems = chats.take(5).toList(); // ← máximo 5
                  final height = (constraints.maxWidth * 0.45).clamp(
                    120.0,
                    280.0,
                  );

                  return SizedBox(
                    height: height,
                    child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: visibleItems.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          ChatTileHome(chat: visibleItems[index]),
                    ),
                  );
                },
              ),

            // Si hay más de 5, mostrar "Ver todos"
            if (chats.length > 5)
              TextButton(
                onPressed: context.goToChats, // navegar a la pantalla completa
                child: Text(
                  'Ver todos (${chats.length})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
