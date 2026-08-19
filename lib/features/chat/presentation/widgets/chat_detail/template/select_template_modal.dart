// lib/features/chat/presentation/widgets/chat_detail/template/select_template_modal.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

// ── Tabs de filtro por tipo de archivo ───────────────────────────────────────

final _tabsDef = [
  (label: 'Todos', icon: AppIcons.plantillas, color: AppColors.primary),
  (label: 'Imagen', icon: AppIcons.image, color: AppColors.success),
  (label: 'Documento', icon: AppIcons.fileWord, color: AppColors.error),
  (label: 'Audio', icon: AppIcons.mic, color: AppColors.warning),
];

// ── Clasificación de extensiones ─────────────────────────────────────────────

bool _esImagen(String ext) {
  return const {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.3gp',
  }.contains(ext.toLowerCase());
}

bool _esDocumento(String ext) {
  return const {
    '.pdf',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.txt',
    '.csv',
  }.contains(ext.toLowerCase());
}

bool _esAudio(String ext) {
  return const {
    '.ogg',
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.opus',
    '.oga',
  }.contains(ext.toLowerCase());
}

// ── Sustitución de variables de plantilla ─────────────────────────────────────

String _formatear(
  String contenido,
  String nombreCliente,
  String apellidoCliente,
  String nombreAsesor,
) {
  return contenido
      .replaceAll('{{nombre_cliente}}', nombreCliente)
      .replaceAll('{{apellido_cliente}}', apellidoCliente)
      .replaceAll('{{nombre_asesor}}', nombreAsesor);
}

// ── Filtrado ──────────────────────────────────────────────────────────────────

List<Plantilla> _filtrar(List<Plantilla> todas, int tab) {
  if (tab == 0) return todas;
  return todas.where((p) {
    final ext = p.archivoExt;
    if (ext.isEmpty) return false;
    return switch (tab) {
      1 => _esImagen(ext),
      2 => _esDocumento(ext),
      3 => _esAudio(ext),
      _ => true,
    };
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class SelectTemplateModal extends StatefulWidget {
  final String nombreCliente;
  final String apellidoCliente;
  final String nombreAsesor;

  const SelectTemplateModal({
    super.key,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.nombreAsesor,
  });

  static Future<Plantilla?> show(
    BuildContext context, {
    required String nombreCliente,
    required String apellidoCliente,
    required String nombreAsesor,
  }) {
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
        child: SelectTemplateModal(
          nombreCliente: nombreCliente,
          apellidoCliente: apellidoCliente,
          nombreAsesor: nombreAsesor,
        ),
      ),
    );
  }

  @override
  State<SelectTemplateModal> createState() => _SelectTemplateModalState();
}

class _SelectTemplateModalState extends State<SelectTemplateModal> {
  int _tabIndex = 0;
  Plantilla? _seleccionada;

  // No cierra el modal — el formulario se apila encima en el mismo
  // Navigator (goToTemplateForm usa NavigationService.navigatorKey, el
  // mismo que showModalBottomSheet resuelve como ancestro, así que ambos
  // comparten stack). Al volver, el SelectTemplateBloc sigue vivo con el
  // mismo estado que tenía — solo se le pide un refresh para traer la
  // plantilla nueva/editada, en vez de recrear todo el modal desde cero.
  Future<void> _abrirFormulario(BuildContext context, {int? idPlantilla}) async {
    final bloc = context.read<SelectTemplateBloc>();
    final guardo = await context.goToTemplateForm(idPlantilla: idPlantilla);
    if (!context.mounted || guardo != true) return;
    bloc.add(const SelectTemplateRefresh());
    if (idPlantilla != null) setState(() => _seleccionada = null);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight * 0.62,
      child: Column(
        children: [
          const _Handle(),

          _Header(
            onClose: () => Navigator.of(context).pop(),
            onNuevo: () => _abrirFormulario(context),
          ),

          _ChipTabBar(
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() {
              _tabIndex = i;
              _seleccionada = null;
            }),
          ),

          Divider(
            height: AppSizing.hairline,
            thickness: AppSizing.hairline,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          Expanded(
            child: BlocBuilder<SelectTemplateBloc, SelectTemplateState>(
              builder: (context, state) {
                if (state is SelectTemplateInitial ||
                    state is SelectTemplateLoading) {
                  return const Center(child: AppLoadingView());
                }
                if (state is SelectTemplateError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<SelectTemplateBloc>().add(
                      SelectTemplateRefresh(),
                    ),
                  );
                }

                final todas = state is SelectTemplateLoaded
                    ? state.templates
                    : <Plantilla>[];
                final filtradas = _filtrar(todas, _tabIndex);

                return _PlantillasTab(
                  plantillas: filtradas,
                  seleccionada: _seleccionada,
                  onSeleccionar: (p) => setState(() => _seleccionada = p),
                  onEditar: (idPlantilla) =>
                      _abrirFormulario(context, idPlantilla: idPlantilla),
                  nombreCliente: widget.nombreCliente,
                  apellidoCliente: widget.apellidoCliente,
                  nombreAsesor: widget.nombreAsesor,
                );
              },
            ),
          ),

          _Footer(
            habilitado: _seleccionada != null,
            onInsertar: () => Navigator.of(context).pop(_seleccionada),
          ),
        ],
      ),
    );
  }
}

// ── Handle ─────────────────────────────────────────────────────────────────────

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
  final VoidCallback onNuevo;
  const _Header({required this.onClose, required this.onNuevo});

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
            onPressed: onNuevo,
            icon: Icon(AppIcons.add, color: colorScheme.primary),
            tooltip: 'Nueva plantilla',
            visualDensity: VisualDensity.compact,
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

// ── Tab principal (filtrado por tipo) ─────────────────────────────────────────

class _PlantillasTab extends StatelessWidget {
  final List<Plantilla> plantillas;
  final Plantilla? seleccionada;
  final ValueChanged<Plantilla> onSeleccionar;
  final ValueChanged<int> onEditar;
  final String nombreCliente;
  final String apellidoCliente;
  final String nombreAsesor;

  const _PlantillasTab({
    required this.plantillas,
    required this.seleccionada,
    required this.onSeleccionar,
    required this.onEditar,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.nombreAsesor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (plantillas.isEmpty) {
      return Center(
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
              'No hay plantillas disponibles',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

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
                  itemCount: plantillas.length,
                  itemBuilder: (_, i) {
                    final p = plantillas[i];
                    final sel = seleccionada?.idPlantilla == p.idPlantilla;
                    return _TemplateItem(
                      plantilla: p,
                      isSelected: sel,
                      onTap: () => onSeleccionar(p),
                      nombreCliente: nombreCliente,
                      apellidoCliente: apellidoCliente,
                      nombreAsesor: nombreAsesor,
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
        Expanded(
          child: _TemplatePreview(
            plantilla: seleccionada,
            onEditar: onEditar,
            nombreCliente: nombreCliente,
            apellidoCliente: apellidoCliente,
            nombreAsesor: nombreAsesor,
          ),
        ),
      ],
    );
  }
}

// ── Item de lista ───────────────────────────────────────────────────────────────

class _TemplateItem extends StatelessWidget {
  final Plantilla plantilla;
  final bool isSelected;
  final VoidCallback onTap;
  final String nombreCliente;
  final String apellidoCliente;
  final String nombreAsesor;

  const _TemplateItem({
    required this.plantilla,
    required this.isSelected,
    required this.onTap,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.nombreAsesor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tieneArchivo = plantilla.archivoNombre.isNotEmpty;
    final contenidoFormateado = _formatear(
      plantilla.contenido,
      nombreCliente,
      apellidoCliente,
      nombreAsesor,
    );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      // Sin contenido de texto no hay nada que mostrar acá —
                      // una plantilla puede ser solo archivo/botones (regla
                      // confirmada por el usuario).
                      if (contenidoFormateado.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          contenidoFormateado,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: AppTextStyles.weightRegular,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

            // ── Card de archivo adjunto ──────────────────────
            if (tieneArchivo) ...[
              const SizedBox(height: AppSpacing.xs),
              TemplateFileCard(
                compact: true,
                nombre: plantilla.archivoNombre,
                ext: plantilla.archivoExt,
              ),
            ],

            // ── Botones de la plantilla ───────────────────────
            if (plantilla.botones.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              _BotonesPreview(botones: plantilla.botones, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Vista previa ───────────────────────────────────────────────────────────────

class _TemplatePreview extends StatelessWidget {
  final Plantilla? plantilla;
  final ValueChanged<int> onEditar;
  final String nombreCliente;
  final String apellidoCliente;
  final String nombreAsesor;

  const _TemplatePreview({
    required this.plantilla,
    required this.onEditar,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.nombreAsesor,
  });

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

    final tieneArchivo = plantilla!.archivoNombre.isNotEmpty;
    final contenidoFormateado = _formatear(
      plantilla!.contenido,
      nombreCliente,
      apellidoCliente,
      nombreAsesor,
    );

    // Bloques opcionales del preview — una plantilla puede no tener texto
    // (solo archivo/botones, regla confirmada por el usuario), así que cada
    // uno se arma solo si aplica y el espaciado entre ellos se intercala
    // abajo, en vez de dejar huecos fijos por bloque ausente.
    final bloques = <Widget>[
      if (contenidoFormateado.trim().isNotEmpty)
        Container(
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
            contenidoFormateado,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      if (tieneArchivo)
        TemplateFileCard(
          nombre: plantilla!.archivoNombre,
          ext: plantilla!.archivoExt,
        ),
      if (plantilla!.botones.isNotEmpty)
        _BotonesPreview(botones: plantilla!.botones),
    ];

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < bloques.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    bloques[i],
                  ],

                  // ── Editar plantilla ─────────────────────────
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => onEditar(plantilla!.idPlantilla),
                    icon: const Icon(AppIcons.edit),
                    label: const Text('Editar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botones de la plantilla (WhatsApp) ───────────────────────────────────────

/// Muestra los botones de una plantilla como chips — solo texto, sin tipos
/// (quick-reply/URL/teléfono), mismo criterio que `TemplateFormBotonesSection`
/// (`chat/CLAUDE.md`). `compact: true` achica ícono/texto/padding para la
/// lista lateral angosta; el default (más grande) se usa en `_TemplatePreview`.
class _BotonesPreview extends StatelessWidget {
  final List<PlantillaBoton> botones;
  final bool compact;

  const _BotonesPreview({required this.botones, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xxs,
      children: [
        for (final boton in botones)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              border: Border.all(
                color: colorScheme.primary,
                width: AppSizing.hairline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.tap,
                  size: compact ? AppSizing.iconInline : AppSizing.iconActionSm,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  boton.texto,
                  style:
                      (compact
                              ? AppTextStyles.labelSmall
                              : AppTextStyles.labelMedium)
                          .copyWith(
                            color: colorScheme.primary,
                            fontWeight: AppTextStyles.weightMedium,
                          ),
                ),
              ],
            ),
          ),
      ],
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
