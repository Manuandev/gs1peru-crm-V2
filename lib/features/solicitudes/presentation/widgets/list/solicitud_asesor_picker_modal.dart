// lib/features/solicitudes/presentation/widgets/list/solicitud_asesor_picker_modal.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

/// Modal de búsqueda de asesor (por nombre o código) para el chip "Asesores"
/// de la lista de Solicitudes. Retorna el código de asesor elegido, o `null`
/// si se cierra sin seleccionar (back, tap fuera, o botón de cerrar) — el
/// llamador debe interpretar `null` como "volver al filtro Todas".
///
/// Los asesores mostrados son los que aparecen como "Ejecutivo responsable"
/// en las solicitudes cargadas ([SolicitudListBloc._buildAsesoresDisponibles])
/// — no se consulta un catálogo aparte.
class SolicitudAsesorPickerModal extends StatefulWidget {
  final List<AsesorResumen> asesores;
  final String? seleccionadoActual;

  const SolicitudAsesorPickerModal({
    super.key,
    required this.asesores,
    this.seleccionadoActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required List<AsesorResumen> asesores,
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
        asesores: asesores,
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

  List<AsesorResumen> _filtrar() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.asesores;
    return widget.asesores
        .where(
          (a) =>
              a.nombre.toLowerCase().contains(q) ||
              a.cod.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final filtrados = _filtrar();

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
            child: widget.asesores.isEmpty
                ? const AppEmptyView(
                    message: 'No hay asesores en las solicitudes cargadas.',
                  )
                : filtrados.isEmpty
                ? const AppEmptyView(message: 'No se encontraron asesores.')
                : ListView.separated(
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
                        isSelected: asesor.cod == widget.seleccionadoActual,
                        onTap: () => Navigator.of(context).pop(asesor.cod),
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
  final AsesorResumen asesor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AsesorTile({
    required this.asesor,
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
                    asesor.cod,
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
                '${asesor.cantidad}',
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
