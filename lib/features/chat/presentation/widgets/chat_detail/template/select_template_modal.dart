// lib/features/chat/presentation/widgets/chat_detail/template/select_template_modal.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

// ── Demo (se usa cuando el SP aún no devuelve datos) ──────────────────────────

const _demoTemplates = [
  Plantilla(
    idPlantilla: 1,
    nombre: 'Bienvenida',
    contenido:
        '¡Hola {{nombre_cliente}}! 👋\n\n'
        'Gracias por escribirnos.\n'
        'En GS1 Perú te ayudamos a desarrollar habilidades prácticas '
        'con nuestros cursos especializados en Excel, Power BI y más.\n\n'
        'Cuéntanos, ¿en qué curso estás interesado para enviarte más información?',
    nombreCampania: '',
    nombreOportunidad: '',
    ibActivo: true,
    idMeta: '',
    estadoMeta: 'APPROVED',
  ),
  Plantilla(
    idPlantilla: 2,
    nombre: 'Seguimiento',
    contenido:
        'Hola {{nombre_cliente}}, espero que estés bien. 😊\n\n'
        'Te escribo para dar seguimiento a tu interés en nuestros cursos. '
        '¿Tienes alguna duda que pueda resolver?',
    nombreCampania: '',
    nombreOportunidad: '',
    ibActivo: true,
    idMeta: '',
    estadoMeta: 'APPROVED',
  ),
];

// ── Tabs (icon + color propio) ────────────────────────────────────────────────

final _tabsDef = [
  (label: 'Plantillas', icon: AppIcons.plantillas, color: AppColors.primary),
  (label: 'Brochure PDF', icon: AppIcons.pdf, color: AppColors.error),
  (label: 'Imagen', icon: AppIcons.image, color: AppColors.success),
  (label: 'Documento', icon: AppIcons.fileWord, color: AppColors.info),
  (label: 'Audio', icon: AppIcons.mic, color: AppColors.warning),
];

// ─────────────────────────────────────────────────────────────────────────────

class SelectTemplateModal extends StatefulWidget {
  const SelectTemplateModal({super.key});

  static Future<Plantilla?> show(BuildContext context) {
    return showModalBottomSheet<Plantilla?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      builder: (ctx) => BlocProvider(
        create: (_) => SelectTemplateBloc(
          getData: GetTemplatesUseCase(ctx.read<ChatRepository>()),
        )..add(const SelectTemplateStarted()),
        child: const SelectTemplateModal(),
      ),
    );
  }

  @override
  State<SelectTemplateModal> createState() => _SelectTemplateModalState();
}

class _SelectTemplateModalState extends State<SelectTemplateModal> {
  int _tabIndex = 0;
  Plantilla? _seleccionada;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight * 0.62,
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────
          const _Handle(),

          // ── Header ────────────────────────────────────────────
          _Header(onClose: () => Navigator.of(context).pop()),

          // ── Chip tabs ─────────────────────────────────────────
          _ChipTabBar(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() {
              _tabIndex = i;
              if (i != 0) _seleccionada = null;
            }),
          ),

          Divider(
            height: AppSizing.hairline,
            thickness: AppSizing.hairline,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          // ── Cuerpo ────────────────────────────────────────────
          Expanded(
            child: _tabIndex == 0
                ? _PlantillasTab(
                    seleccionada: _seleccionada,
                    onSeleccionar: (p) => setState(() => _seleccionada = p),
                  )
                : _PlaceholderTab(label: _tabsDef[_tabIndex].label),
          ),

          // ── Botón insertar ────────────────────────────────────
          _Footer(
            habilitado: _seleccionada != null && _tabIndex == 0,
            onInsertar: () => Navigator.of(context).pop(_seleccionada),
          ),
        ],
      ),
    );
  }
}

// ── Handle (barrita superior) ─────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          width: AppSizing.sheetHandleWidth,
          height: AppSizing.sheetHandleHeight,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Enviar plantilla o adjunto',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(AppIcons.close, color: colorScheme.onSurfaceVariant),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ── Chip tab bar ───────────────────────────────────────────────────────────────

class _ChipTabBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  const _ChipTabBar({required this.tabIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        itemCount: _tabsDef.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final tab = _tabsDef[i];
          final selected = tabIndex == i;

          return GestureDetector(
            onTap: () => onTabChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm2,
                vertical: AppSpacing.xs,
              ),
              decoration: selected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppSizing.radiusCircular,
                      ),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: AppSizing.borderFocusWidth,
                      ),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: AppSizing.iconActionSm,
                    color: selected ? colorScheme.primary : tab.color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    tab.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: selected
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Tab de plantillas ──────────────────────────────────────────────────────────

class _PlantillasTab extends StatelessWidget {
  final Plantilla? seleccionada;
  final ValueChanged<Plantilla> onSeleccionar;

  const _PlantillasTab({
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SelectTemplateBloc, SelectTemplateState>(
      builder: (context, state) {
        if (state is SelectTemplateInitial || state is SelectTemplateLoading) {
          return const Center(child: AppLoadingView());
        }
        if (state is SelectTemplateError) {
          return AppErrorView(
            message: state.message,
            onRetry: () =>
                context.read<SelectTemplateBloc>().add(SelectTemplateRefresh()),
          );
        }

        final templates =
            state is SelectTemplateLoaded && state.templates.isNotEmpty
            ? state.templates
            : _demoTemplates;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Lista izquierda ───────────────────────────────────
            SizedBox(
              width: 172,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      'Plantillas de mensajes',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        AppSpacing.xxs,
                        AppSpacing.sm,
                        AppSpacing.sm,
                      ),
                      itemCount: templates.length,
                      itemBuilder: (_, i) {
                        final p = templates[i];
                        final sel = seleccionada?.idPlantilla == p.idPlantilla;
                        return _TemplateItem(
                          plantilla: p,
                          isSelected: sel,
                          onTap: () => onSeleccionar(p),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Divisor ──────────────────────────────────────────
            VerticalDivider(
              width: AppSizing.hairline,
              thickness: AppSizing.hairline,
              color: colorScheme.outlineVariant,
            ),

            // ── Vista previa ──────────────────────────────────────
            Expanded(child: _TemplatePreview(plantilla: seleccionada)),
          ],
        );
      },
    );
  }
}

// ── Item de lista ───────────────────────────────────────────────────────────────

class _TemplateItem extends StatelessWidget {
  final Plantilla plantilla;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateItem({
    required this.plantilla,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary,
                  width: AppSizing.borderFocusWidth,
                )
              : Border.all(
                  color: colorScheme.outlineVariant,
                  width: AppSizing.hairline,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Contenedor de ícono ──────────────────────────
            Container(
              width: AppSizing.iconContainerMd,
              height: AppSizing.iconContainerMd,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
              ),
              child: Icon(
                AppIcons.chat,
                size: AppSizing.iconSearch,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantilla.nombre,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    plantilla.contenido,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: AppTextStyles.weightRegular,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizing.iconSearch,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vista previa ───────────────────────────────────────────────────────────────

class _TemplatePreview extends StatelessWidget {
  final Plantilla? plantilla;
  const _TemplatePreview({required this.plantilla});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (plantilla == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.plantillas,
                size: AppSizing.iconLg,
                color: colorScheme.onSurface.withValues(
                  alpha: AppColors.opacityEmptyIcon,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Selecciona una plantilla\npara ver la vista previa',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista previa',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizing.radiusMd),
                    topRight: Radius.circular(AppSizing.radiusMd),
                    bottomRight: Radius.circular(AppSizing.radiusMd),
                    bottomLeft: Radius.circular(AppSizing.radiusXs),
                  ),
                ),
                child: Text(
                  plantilla!.contenido,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder tabs ────────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.fileOutlined,
            size: AppSizing.iconXl,
            color: colorScheme.onSurface.withValues(
              alpha: AppColors.opacityEmptyIcon,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$label\nPróximamente',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ──────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool habilitado;
  final VoidCallback onInsertar;
  const _Footer({required this.habilitado, required this.onInsertar});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: AppSizing.hairline,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: habilitado ? onInsertar : null,
          icon: const Icon(AppIcons.send),
          label: const Text('Insertar en chat'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
