// lib/core/presentation/widgets/navigation/drawer_unidad_selector.dart
//
// Selector de unidad de negocio del drawer. Muestra la unidad activa y, si
// el asesor tiene más de una, al tocarlo abre UnidadSelectorSheet con las
// unidades que devolvió el login. Al elegir otra, UnidadCubit la cambia y
// cada pantalla principal se recarga al cerrarse el drawer.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class DrawerUnidadSelector extends StatelessWidget {
  const DrawerUnidadSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnidadCubit, UnidadState>(
      builder: (context, unidad) {
        return BlocBuilder<CatalogsBloc, CatalogsState>(
          builder: (context, catalogos) {
            final nombre = unidad.tieneUnidades
                ? UnidadSelectorSheet.nombreUnidad(
                    catalogos,
                    unidad.idUnidadActiva,
                  )
                : 'Sin unidad asignada';
            return _TarjetaUnidad(
              nombre: nombre,
              puedeCambiar: unidad.puedeCambiar,
              onTap: unidad.puedeCambiar
                  ? () => _abrirSelector(context)
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _abrirSelector(BuildContext context) async {
    final elegida = await UnidadSelectorSheet.elegir(context);
    if (elegida == null || !context.mounted) return;

    // Cierra el drawer: la pantalla de origen escucha UnidadCubit y se
    // recarga con la nueva unidad.
    Navigator.of(context).pop();
    await UnidadCubit.instance.cambiarUnidad(elegida);
  }
}

// ── Tarjeta con la unidad activa ─────────────────────────────────────────────

class _TarjetaUnidad extends StatelessWidget {
  final String nombre;
  final bool puedeCambiar;
  final VoidCallback? onTap;

  const _TarjetaUnidad({
    required this.nombre,
    required this.puedeCambiar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: colorScheme.primary.withValues(
          alpha: AppColors.opacityIconTint,
        ),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.business,
                  color: colorScheme.primary,
                  size: AppSizing.iconNav,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unidad de negocio',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (puedeCambiar)
                  Icon(
                    AppIcons.arrowDown,
                    color: colorScheme.onSurfaceVariant,
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
