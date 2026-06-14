// lib/features/chat/presentation/widgets/chat_list/chat_list_search.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class ChatListSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  const ChatListSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: CustomTextField(
        controller: controller,
        hint: 'Buscar por nombre, teléfono o empresa...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                )
              : const SizedBox.shrink(),
        ),
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
