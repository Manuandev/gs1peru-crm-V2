import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:app_crm/features/home/presentation/widgets/dashboard/tiles/chat_tile_home.dart';
import 'package:flutter/material.dart';

class ChatsSection extends StatelessWidget {
  final List<ChatItem> chats;
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
              const _EmptySection(message: 'No tienes chats pendientes')
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
                onPressed: () {}, // navegar a la pantalla completa
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

// Widget reutilizable para cuando no hay datos
class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
