// lib/features/home/presentation/widgets/notifications/notification_filter_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CollapsibleSection extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final List<Widget> children;

  const CollapsibleSection({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.children,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm2,
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: AppSizing.iconActionSm, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  widget.label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.badgePaddingH,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.0 : -0.5,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    AppIcons.expandLess,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),

        Visibility(
          visible: _expanded,
          maintainState: true,
          child: widget.children.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Text(
                      'No tienes ${widget.label.toLowerCase()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(
                          alpha: AppColors.opacityEmptyText,
                        ),
                      ),
                    ),
                  ),
                )
              : Column(children: widget.children),
        ),
      ],
    );
  }
}
