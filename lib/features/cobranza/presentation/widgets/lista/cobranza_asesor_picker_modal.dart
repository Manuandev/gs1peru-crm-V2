// lib/features/cobranza/presentation/widgets/lista/cobranza_asesor_picker_modal.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de la lista de Cobranzas. Retorna el `codUser` elegido, o `null` si se
/// cierra sin seleccionar (back, tap fuera, o botón de cerrar) — el llamador
/// debe interpretar `null` como "volver al filtro Todos".
///
/// Reactivo a [CatalogsBloc] Y a [CobranzaListBloc] — al abrirse, dispara
/// `CatalogsLoadRequested` + `CobranzaListRefresh` (además del ícono manual
/// de refrescar) para que tanto el universo de asesores como el conteo por
/// estado estén al día, no lo que quedó cargado en memoria desde que se
/// entró a la pantalla. El conteo por asesor ([conteosPorAsesor], desglosado
/// por `idEstado`) NO viene del backend, se calcula en [CobranzaListBloc]
/// sobre las cobranzas cargadas — `widget.conteosPorAsesor` es solo el
/// snapshot inicial (evita un parpadeo en blanco mientras llega el refresh);
/// una vez que el bloc reemite, el modal se actualiza solo.
class CobranzaAsesorPickerModal extends StatefulWidget {
  final Map<String, Map<int, int>> conteosPorAsesor;
  final String? seleccionadoActual;

  const CobranzaAsesorPickerModal({
    super.key,
    required this.conteosPorAsesor,
    this.seleccionadoActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required Map<String, Map<int, int>> conteosPorAsesor,
    String? seleccionadoActual,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      builder: (_) => CobranzaAsesorPickerModal(
        conteosPorAsesor: conteosPorAsesor,
        seleccionadoActual: seleccionadoActual,
      ),
    );
  }

  @override
  State<CobranzaAsesorPickerModal> createState() =>
      _CobranzaAsesorPickerModalState();
}

class _CobranzaAsesorPickerModalState
    extends State<CobranzaAsesorPickerModal> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // "Cada que abra esto, que cargue la data" — pedido explícito del
    // usuario, no confiar en el catálogo (sesión) ni en la lista (última
    // vez que se entró a la pantalla) que puedan estar desactualizados.
    context.read<CatalogsBloc>().add(const CatalogsLoadRequested());
    context.read<CobranzaListBloc>().add(const CobranzaListRefresh());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AsesorItem> _filtrar(List<AsesorItem> asesores) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return asesores;
    return asesores
        .where(
          (a) =>
              a.nombre.toLowerCase().contains(q) ||
              a.codUser.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Mientras llega el refresh disparado en initState, se muestra el
    // snapshot con el que se abrió el modal (evita un parpadeo en blanco) —
    // apenas CobranzaListBloc reemite con datos frescos, se usa ese.
    final cobranzaListState = context.watch<CobranzaListBloc>().state;
    final conteosPorAsesor = cobranzaListState is CobranzaListSuccess
        ? cobranzaListState.conteosPorAsesor
        : widget.conteosPorAsesor;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Center(
              child: Container(
                width: AppSizing.sheetHandleWidth,
                height: AppSizing.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AppSizing.radiusCircular,
                  ),
                ),
              ),
            ),
          ),
          Padding(
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
                    'Seleccionar asesor',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<CatalogsBloc>().add(
                      const CatalogsLoadRequested(),
                    );
                    context.read<CobranzaListBloc>().add(
                      const CobranzaListRefresh(),
                    );
                  },
                  icon: Icon(
                    AppIcons.refresh,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    AppIcons.close,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: CustomTextField(
              controller: _searchCtrl,
              hint: 'Buscar por nombre o código',
              prefixIcon: Icon(AppIcons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<CatalogsBloc, CatalogsState>(
              builder: (context, state) {
                if (state is CatalogsLoading || state is CatalogsInitial) {
                  return const AppLoadingView();
                }
                if (state is CatalogsError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<CatalogsBloc>().add(
                      const CatalogsLoadRequested(),
                    ),
                  );
                }

                final asesores = (state as CatalogsLoaded).asesores;
                final filtrados = _filtrar(asesores);

                if (asesores.isEmpty) {
                  return const AppEmptyView(
                    message: 'No hay asesores en el catálogo.',
                  );
                }
                if (filtrados.isEmpty) {
                  return const AppEmptyView(
                    message: 'No se encontraron asesores.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xxs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final asesor = filtrados[i];
                    return _AsesorTile(
                      asesor: asesor,
                      conteoPorEstado:
                          conteosPorAsesor[asesor.codUser] ?? const {},
                      isSelected: asesor.codUser == widget.seleccionadoActual,
                      onTap: () => Navigator.of(context).pop(asesor.codUser),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AsesorTile extends StatelessWidget {
  final AsesorItem asesor;
  final Map<int, int> conteoPorEstado;
  final bool isSelected;
  final VoidCallback onTap;

  const _AsesorTile({
    required this.asesor,
    required this.conteoPorEstado,
    required this.isSelected,
    required this.onTap,
  });

  // Mismo orden/labels/íconos que CobranzaSummaryCards/CobranzaDetalleStepper
  // — 0 Pend.deDocumento, 2 Facturar, 5 Pend.factura, 3 Cancelado.
  static const _estados = [
    (id: 0, label: 'Pend. documento', icon: AppIcons.fileOutlined),
    (id: 2, label: 'Facturar', icon: AppIcons.receipt),
    (id: 5, label: 'Pend. pago', icon: AppIcons.time),
    (id: 3, label: 'Cancelado', icon: AppIcons.checkCircle),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = conteoPorEstado.values.fold(0, (a, b) => a + b);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected
                ? AppSizing.borderFocusWidth
                : AppSizing.hairline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusXs,
                  backgroundColor: asesor.nombre.avatarColor,
                  child: Text(
                    asesor.nombre.initials,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
                if (asesor.disponible)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: AppSizing.dotIndicatorSize,
                      height: AppSizing.dotIndicatorSize,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: AppSizing.hairline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asesor.nombre,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    asesor.codUser,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Wrap(
                      spacing: AppSpacing.xxs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        for (final e in _estados)
                          if ((conteoPorEstado[e.id] ?? 0) > 0)
                            _EstadoBadgeChico(
                              icon: e.icon,
                              label: e.label,
                              color: colorEstadoGes(e.id),
                              cantidad: conteoPorEstado[e.id]!,
                            ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              ),
              child: Text(
                '$total',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chip chico: ícono + cantidad, coloreado por estado — mismo lenguaje visual
// que CobranzaSummaryCards, en miniatura. El label completo va en el
// Tooltip (accesible sin ocupar espacio horizontal en la fila).
class _EstadoBadgeChico extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int cantidad;

  const _EstadoBadgeChico({
    required this.icon,
    required this.label,
    required this.color,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizing.iconInline, color: color),
            const SizedBox(width: 2),
            Text(
              '$cantidad',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: AppTextStyles.sizeXs,
                fontWeight: AppTextStyles.weightSemiBold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
