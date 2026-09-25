// lib/features/home/presentation/widgets/dashboard/home_unidad_chip.dart
//
// Chip con la unidad de negocio activa, para el título del AppBar del Home
// (debajo de "Hola, …"). PROPUESTA 2026-09-25, pendiente de aprobación: hoy
// NO se usa — en home_view.dart está comentado y sigue el subtítulo de
// siempre. Para activarlo: comentar el subtítulo y descomentar el chip ahí.
//
// - Varias unidades → tocable, abre UnidadSelectorSheet (el mismo del drawer).
// - Una unidad     → solo informa (sin flecha).
// - Sin unidades   → "Sin unidad asignada", borde tenue, no tocable.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class HomeUnidadChip extends StatelessWidget {
  const HomeUnidadChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnidadCubit, UnidadState>(
      builder: (context, unidad) {
        return BlocBuilder<CatalogsBloc, CatalogsState>(
          builder: (context, catalogos) {
            if (!unidad.tieneUnidades) {
              return const _Chip(
                texto: 'Sin unidad asignada',
                conFondo: false,
              );
            }
            return _Chip(
              texto: UnidadSelectorSheet.nombreUnidad(
                catalogos,
                unidad.idUnidadActiva,
              ),
              conFondo: true,
              onTap: unidad.puedeCambiar ? () => _cambiar(context) : null,
            );
          },
        );
      },
    );
  }

  // El Home escucha UnidadCubit y se recarga solo al cambiar la unidad.
  Future<void> _cambiar(BuildContext context) async {
    final elegida = await UnidadSelectorSheet.elegir(context);
    if (elegida == null) return;
    await UnidadCubit.instance.cambiarUnidad(elegida);
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final bool conFondo;
  final VoidCallback? onTap;

  const _Chip({required this.texto, required this.conFondo, this.onTap});

  @override
  Widget build(BuildContext context) {
    final forma = StadiumBorder(
      side: BorderSide(
        color: AppColors.textOnDark.withValues(
          alpha: conFondo ? AppColors.opacityBorderOnDark : AppColors.opacityHint,
        ),
      ),
    );

    return Material(
      color: conFondo
          ? AppColors.textOnDark.withValues(alpha: AppColors.opacityAvatarBg)
          : AppColors.transparent,
      shape: forma,
      child: InkWell(
        customBorder: forma,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.business,
                size: AppSizing.iconXs,
                color: AppColors.textOnDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xxs),
                const Icon(
                  AppIcons.arrowDown,
                  size: AppSizing.iconXs,
                  color: AppColors.textOnDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
