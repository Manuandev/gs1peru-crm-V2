// lib/features/lead/presentation/widgets/list/lead_asesor_picker_modal.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de Seguimiento. Retorna el `codUser` elegido, o `null` si se cierra sin
/// seleccionar (back, tap fuera, o botón de cerrar) — el llamador debe
/// interpretar `null` como "volver al filtro Todos".
///
/// La lista de asesores se lee en vivo de [CatalogsBloc] (catálogo global,
/// cargado una sola vez al iniciar sesión) — el botón de refrescar del
/// header dispara [CatalogsLoadRequested] para traer asesores recién
/// asignados sin cerrar sesión.
class LeadAsesorPickerModal extends StatefulWidget {
  final Map<String, int> conteosPorAsesor;
  final String? seleccionadoActual;

  const LeadAsesorPickerModal({
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
      builder: (_) => LeadAsesorPickerModal(
        conteosPorAsesor: conteosPorAsesor,
        seleccionadoActual: seleccionadoActual,
      ),
    );
  }

  @override
  State<LeadAsesorPickerModal> createState() => _LeadAsesorPickerModalState();
}

class _LeadAsesorPickerModalState extends State<LeadAsesorPickerModal> {
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
                BlocBuilder<CatalogsBloc, CatalogsState>(
                  builder: (context, state) {
                    final refrescando = state is CatalogsLoading;
                    return IconButton(
                      tooltip: 'Actualizar lista de asesores',
                      onPressed: refrescando
                          ? null
                          : () => context.read<CatalogsBloc>().add(
                              const CatalogsLoadRequested(),
                            ),
                      icon: refrescando
                          ? SizedBox(
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSizing.spinnerStrokeSmall,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              AppIcons.refresh,
                              color: colorScheme.onSurfaceVariant,
                            ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
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
                final asesores = state is CatalogsLoaded
                    ? state.asesores
                    : const <AsesorItem>[];
                final filtrados = _filtrar(asesores);

                if (state is CatalogsLoading && asesores.isEmpty) {
                  return const AppLoadingView();
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
              clipBehavior: Clip.none,
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
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: AppSizing.dotIndicatorSize,
                      height: AppSizing.dotIndicatorSize,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: AppSizing.canalBadgeBorder,
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
