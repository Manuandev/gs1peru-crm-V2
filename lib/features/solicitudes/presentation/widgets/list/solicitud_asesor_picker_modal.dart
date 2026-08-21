// lib/features/solicitudes/presentation/widgets/list/solicitud_asesor_picker_modal.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de la lista de Solicitudes. Retorna el `codUser` elegido, o `null` si se
/// cierra sin seleccionar (back, tap fuera, o botón de cerrar) — el llamador
/// debe interpretar `null` como "volver al filtro Todas".
///
/// No dispara ninguna recarga al abrirse (revertido 2026-08-21, pedido
/// explícito del usuario, mismo cambio que `CobranzaAsesorPickerModal`) —
/// usa directo el universo de asesores ya cargado en [CatalogsBloc] (global,
/// cargado una vez al iniciar sesión) y [conteosPorAsesor], el snapshot que
/// ya calculó `SolicitudListBloc` sobre la lista pintada en pantalla. Antes
/// recargaba ambos al abrir (`CatalogsLoadRequested` + `SolicitudListRefresh`)
/// y quedaba reactivo a `SolicitudListBloc` — se quitó por el mismo motivo
/// que en Cobranza: riesgo de que el modal se abra desde un `BuildContext`
/// sin `Provider<SolicitudListBloc>` en su árbol, y porque el usuario
/// prefiere que solo muestre lo que ya está cargado, sin ninguna llamada de
/// red extra al abrir el picker.
class SolicitudAsesorPickerModal extends StatefulWidget {
  final Map<String, Map<bool, int>> conteosPorAsesor;
  final String? seleccionadoActual;

  const SolicitudAsesorPickerModal({
    super.key,
    required this.conteosPorAsesor,
    this.seleccionadoActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required Map<String, Map<bool, int>> conteosPorAsesor,
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
      builder: (_) => SolicitudAsesorPickerModal(
        conteosPorAsesor: conteosPorAsesor,
        seleccionadoActual: seleccionadoActual,
      ),
    );
  }

  @override
  State<SolicitudAsesorPickerModal> createState() =>
      _SolicitudAsesorPickerModalState();
}

class _SolicitudAsesorPickerModalState
    extends State<SolicitudAsesorPickerModal> {
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

    final conteosPorAsesor = widget.conteosPorAsesor;

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
                  borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
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
                      conteoPorValidado:
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
  // false = sin validar, true = validado — mismo criterio que SolicitudFiltro.
  final Map<bool, int> conteoPorValidado;
  final bool isSelected;
  final VoidCallback onTap;

  const _AsesorTile({
    required this.asesor,
    required this.conteoPorValidado,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sinValidar = conteoPorValidado[false] ?? 0;
    final validados = conteoPorValidado[true] ?? 0;
    final total = sinValidar + validados;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? AppSizing.borderFocusWidth : AppSizing.hairline,
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
                        if (sinValidar > 0)
                          _EstadoBadgeChico(
                            icon: AppIcons.time,
                            label: 'Sin validar',
                            color: AppColors.warning,
                            cantidad: sinValidar,
                          ),
                        if (validados > 0)
                          _EstadoBadgeChico(
                            icon: AppIcons.checkCircle,
                            label: 'Validado',
                            color: AppColors.success,
                            cantidad: validados,
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
// que CobranzaAsesorPickerModal._EstadoBadgeChico.
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
