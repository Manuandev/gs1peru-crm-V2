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

        return NavigationBar(
          selectedIndex: indiceActivo,
          onDestinationSelected: (i) => _navegar(context, i, indiceActivo),
          destinations: [
            // Inicio
            const NavigationDestination(
              icon: Icon(AppIcons.home),
              selectedIcon: Icon(AppIcons.homeFilled),
              label: 'Inicio',
            ),

            // Chats con badge de conversaciones pendientes
            NavigationDestination(
              icon: Badge(
                isLabelVisible: badgeChats != null,
                label: badgeChats != null ? Text('$badgeChats') : null,
                child: const Icon(AppIcons.message),
              ),
              selectedIcon: Badge(
                isLabelVisible: badgeChats != null,
                label: badgeChats != null ? Text('$badgeChats') : null,
                child: const Icon(AppIcons.message),
              ),
              label: 'Chats',
            ),

            // Seguimiento
            const NavigationDestination(
              icon: Icon(AppIcons.users),
              label: 'Seguimiento',
            ),

            // Solicitudes
            const NavigationDestination(
              icon: Icon(AppIcons.email),
              label: 'Solicitudes',
            ),

            // Cobranza
            const NavigationDestination(
              icon: Icon(AppIcons.moneda),
              label: 'Cobranza',
            ),
          ],
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
