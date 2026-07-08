// lib/features/cobranza/presentation/widgets/lista/cobranza_asesor_picker_modal.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de la lista de Cobranzas. Retorna el `codUser` elegido, o `null` si se
/// cierra sin seleccionar (back, tap fuera, o botón de cerrar) — el llamador
/// debe interpretar `null` como "volver al filtro Todos".
///
/// Reactivo a [CatalogsBloc] (no recibe la lista de asesores como snapshot
/// estático) — el ícono de refrescar en el header dispara
/// `CatalogsLoadRequested`. El conteo por asesor ([conteosPorAsesor]) NO viene
/// del backend, se calcula en [CobranzaListBloc] sobre las cobranzas cargadas.
class CobranzaAsesorPickerModal extends StatefulWidget {
  final Map<String, int> conteosPorAsesor;
  final String? seleccionadoActual;

  const CobranzaAsesorPickerModal({
    super.key,
    required this.conteosPorAsesor,
    this.seleccionadoActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required Map<String, int> conteosPorAsesor,
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
                  onPressed: () => context.read<CatalogsBloc>().add(
                    const CatalogsLoadRequested(),
                  ),
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
                      cantidad: widget.conteosPorAsesor[asesor.codUser] ?? 0,
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
  final int cantidad;
  final bool isSelected;
  final VoidCallback onTap;

  const _AsesorTile({
    required this.asesor,
    required this.cantidad,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                '$cantidad',
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
