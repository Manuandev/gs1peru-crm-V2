// lib/features/chat/presentation/widgets/chat_detail/template/select_template_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class SelectTemplatePortrait extends StatefulWidget {
  final SelectTemplateLoaded state;

  const SelectTemplatePortrait({super.key, required this.state});

  @override
  State<SelectTemplatePortrait> createState() => _SelectTemplatePortraitState();
}

class _SelectTemplatePortraitState extends State<SelectTemplatePortrait> {
  Template? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.state.templates.isEmpty) return const _EmptyTemplate();

    return Column(
      children: [
        // ── Lista de cards ────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            itemCount: widget.state.templates.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.smPlus),
            itemBuilder: (context, index) {
              final template = widget.state.templates[index];
              final isSelected =
                  _selected?.idPlantilla == template.idPlantilla;

              return _TemplateCard(
                template: template,
                isSelected: isSelected,
                onTap: () => setState(() => _selected = template),
              );
            },
          ),
        ),

        // ── Botón enviar ──────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _selected != null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selected == null
                      ? null
                      : () => context.goBack<Template>(_selected),
                  icon: const Icon(AppIcons.send),
                  label: const Text('Enviar plantilla'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.chipPaddingH,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                    ),
                  ),
                ),
              ),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── Card individual ───────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final Template template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tieneArchivo = template.rutaArchivo.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizing.radiusMdLg),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected
                ? AppSizing.borderFocusWidth
                : AppSizing.hairline,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.chipPaddingH),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ícono tipo ──────────────────────────────────
            Container(
              width: AppSizing.iconContainerMd,
              height: AppSizing.iconContainerMd,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(
                        alpha: AppColors.opacityAvatarBg,
                      )
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
              ),
              child: Icon(
                tieneArchivo
                    ? _iconForExt(template.extensionArchivo)
                    : AppIcons.chat,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: AppSizing.iconSearch,
              ),
            ),

            const SizedBox(width: AppSpacing.sm2),

            // ── Nombre + preview ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.nombre,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (template.detalle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      template.detalle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (tieneArchivo) ...[
                    const SizedBox(height: AppSpacing.chipGap),
                    Row(
                      children: [
                        Icon(
                          AppIcons.attach,
                          size: AppSizing.iconInline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          template.nombreArchivo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Check seleccionado ──────────────────────────
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  AppIcons.checkCircleFilled,
                  color: colorScheme.primary,
                  size: AppSizing.iconSearch,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForExt(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(e)) {
      return AppIcons.image;
    }
    if (['mp4', 'mov', 'avi'].contains(e)) return AppIcons.videocam;
    if (['mp3', 'm4a', 'ogg', 'wav'].contains(e)) return AppIcons.mic;
    if (['pdf'].contains(e)) return AppIcons.pdf;
    return AppIcons.fileOutlined;
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTemplate extends StatelessWidget {
  const _EmptyTemplate();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.emptyStateTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.editNote,
            size: AppSizing.iconXl,
            color: colorScheme.onSurface.withValues(
              alpha: AppColors.opacityEmptyIcon,
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'No hay plantillas',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: AppColors.opacityEmptyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
