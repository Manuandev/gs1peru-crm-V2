// lib/core/presentation/widgets/footer_botton.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

/// Barra de navegación inferior global — análoga a [AppDrawerWidget].
///
/// Activar desde cualquier pantalla con [BasePage.showBottomNav].
/// Lee badges de [DrawerBloc] (global) y auto-detecta la ruta activa.
///
/// DESTINOS: Inicio · Chats · Seguimiento · Solicitudes · Cobranza
class AppBottomNavWidget extends StatelessWidget {
  const AppBottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final rutaActual = ModalRoute.of(context)?.settings.name;
    final indiceActivo = _indiceDesdeRuta(rutaActual);

    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) {
        final badgeChats = state is DrawerLoaded && state.conversaciones > 0
            ? state.conversaciones
            : null;

        return _BarraNavegacion(
          indiceActivo: indiceActivo,
          badgeChats: badgeChats,
          alSeleccionar: (i) => _navegar(context, i, indiceActivo),
        );
      },
    );
  }

  /// Mapea la ruta actual al índice de navegación.
  /// startsWith cubre sub-rutas: /chats/detalle → índice 1.
  int _indiceDesdeRuta(String? ruta) {
    if (ruta == null) return 0;
    if (ruta.startsWith(AppRoutes.chats)) return 1;
    if (ruta.startsWith(AppRoutes.seguimiento)) return 2;
    if (ruta.startsWith(AppRoutes.solicitudes)) return 3;
    if (ruta.startsWith(AppRoutes.cobranza)) return 4;
    return 0;
  }

  void _navegar(BuildContext context, int indiceNuevo, int indiceActual) {
    if (indiceNuevo == indiceActual) return;
    switch (indiceNuevo) {
      case 0:
        context.goToHome();
      case 1:
        context.goToChats();
      case 2:
        context.goToSeguimiento();
      case 3:
        context.goToSolicitudes();
      case 4:
        context.goToCobranza();
    }
  }
}

// ── Contenedor de la barra ──────────────────────────────────────────────────

class _BarraNavegacion extends StatelessWidget {
  final int indiceActivo;
  final int? badgeChats;
  final void Function(int) alSeleccionar;

  const _BarraNavegacion({
    required this.indiceActivo,
    required this.badgeChats,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _ItemNav(
            icono: AppIcons.home,
            etiqueta: 'Inicio',
            activo: indiceActivo == 0,
            alTap: () => alSeleccionar(0),
          ),
          _ItemNav(
            icono: AppIcons.message,
            etiqueta: 'Chats',
            badge: badgeChats,
            activo: indiceActivo == 1,
            alTap: () => alSeleccionar(1),
          ),
          _ItemNav(
            icono: AppIcons.users,
            etiqueta: 'Seguimiento',
            activo: indiceActivo == 2,
            alTap: () => alSeleccionar(2),
          ),
          // _ItemNav(
          //   icono: AppIcons.email,
          //   etiqueta: 'Solicitudes',
          //   activo: indiceActivo == 3,
          //   alTap: () => alSeleccionar(3),
          // ),
          _ItemNav(
            icono: AppIcons.moneda,
            etiqueta: 'Cobranza',
            activo: indiceActivo == 4,
            alTap: () => alSeleccionar(4),
          ),
        ],
      ),
    );
  }
}

// ── Ítem individual de la barra ─────────────────────────────────────────────

class _ItemNav extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final int? badge;
  final bool activo;
  final VoidCallback alTap;

  const _ItemNav({
    required this.icono,
    required this.etiqueta,
    this.badge,
    required this.activo,
    required this.alTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: alTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono con badge opcional
                  badge != null
                      ? Badge(
                          label: Text('$badge'),
                          child: Icon(
                            icono,
                            color: color,
                            size: AppSizing.iconNav,
                          ),
                        )
                      : Icon(icono, color: color, size: AppSizing.iconNav),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    etiqueta,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: activo
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                  ),
                ],
              ),
            ),
            // Barrita indicadora inferior del ítem activo
            activo
                ? Container(
                    height: AppSizing.navIndicatorHeight,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizing.radiusXxs),
                      ),
                    ),
                  )
                : const SizedBox(height: AppSizing.navIndicatorHeight),
          ],
        ),
      ),
    );
  }
}
