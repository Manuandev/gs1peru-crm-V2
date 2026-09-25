// lib/core/presentation/widgets/navigation/unidad_selector_sheet.dart
//
// Bottom sheet "Cambiar unidad de negocio" — lista las unidades que devolvió
// el login, con la activa resaltada. Lo abren el selector del drawer
// (DrawerUnidadSelector) y el chip de unidad del Home (HomeUnidadChip).

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class UnidadSelectorSheet {
  UnidadSelectorSheet._();

  /// Abre el selector y devuelve la unidad elegida, o `null` si se cerró sin
  /// elegir o se eligió la que ya estaba activa. No cambia nada por sí solo:
  /// el llamador decide qué hacer antes de `UnidadCubit.cambiarUnidad()`.
  static Future<int?> elegir(BuildContext context) async {
    final unidad = context.read<UnidadCubit>().state;
    final elegida = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      builder: (_) => _SelectorUnidadSheet(unidad: unidad),
    );
    if (elegida == null || elegida == unidad.idUnidadActiva) return null;
    return elegida;
  }

  /// Nombre de la unidad desde el catálogo; si todavía no cargó o no la
  /// trae, un texto genérico con el id.
  static String nombreUnidad(CatalogsState catalogos, int? idUnidad) {
    final nombre = catalogos is CatalogsLoaded
        ? catalogos.nombreUnidad(idUnidad)
        : null;
    return nombre ?? 'Unidad $idUnidad';
  }
}

// ── Bottom sheet con las unidades asignadas ──────────────────────────────────

class _SelectorUnidadSheet extends StatelessWidget {
  final UnidadState unidad;
  const _SelectorUnidadSheet({required this.unidad});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Cambiar unidad de negocio',
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
          Flexible(
            child: BlocBuilder<CatalogsBloc, CatalogsState>(
              builder: (context, catalogos) {
                return ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  children: [
                    for (final id in unidad.unidades)
                      _OpcionUnidad(
                        nombre: UnidadSelectorSheet.nombreUnidad(
                          catalogos,
                          id,
                        ),
                        activa: id == unidad.idUnidadActiva,
                        onTap: () => Navigator.of(context).pop(id),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionUnidad extends StatelessWidget {
  final String nombre;
  final bool activa;
  final VoidCallback onTap;

  const _OpcionUnidad({
    required this.nombre,
    required this.activa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = activa ? colorScheme.primary : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Material(
        color: activa
            ? colorScheme.primary.withValues(alpha: AppColors.opacityActiveItem)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + AppSpacing.xxs,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.business,
                  color: activa ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: AppSizing.iconNav,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    nombre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: activa
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                  ),
                ),
                if (activa)
                  Icon(
                    AppIcons.check,
                    color: colorScheme.primary,
                    size: AppSizing.iconNav,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
