// lib/features/lead/presentation/widgets/seguimiento/seguimiento_portrait.dart
//
// Lista paginada de Seguimiento. Reusa los widgets puros LeadListFilterChips /
// LeadListStatsRow / LeadCard (sin tocarlos) — lo nuevo es el scroll infinito,
// el pie de página y los 3 estados vacíos.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoPortrait extends StatefulWidget {
  final SeguimientoCargado estado;

  const SeguimientoPortrait({super.key, required this.estado});

  @override
  State<SeguimientoPortrait> createState() => _SeguimientoPortraitState();
}

class _SeguimientoPortraitState extends State<SeguimientoPortrait> {
  final ScrollController _scroll = ScrollController();

  // Dispara la carga al 80% del scroll, no al final.
  static const double _umbral = 0.8;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rellenarSiNoScrollea());
  }

  @override
  void didUpdateWidget(covariant SeguimientoPortrait old) {
    super.didUpdateWidget(old);
    // Tras cada nueva página / cambio de filtro: si el contenido no llena la
    // pantalla (tablet, landscape, pocas filas) el listener nunca llega al
    // umbral y la lista quedaría muerta — pedir otra página.
    WidgetsBinding.instance.addPostFrameCallback((_) => _rellenarSiNoScrollea());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels >= pos.maxScrollExtent * _umbral) {
      context.read<SeguimientoBloc>().add(const SeguimientoPaginaSolicitada());
    }
  }

  void _rellenarSiNoScrollea() {
    if (!mounted || !_scroll.hasClients) return;
    final e = widget.estado;
    if (e.recargandoLista || e.items.isEmpty || !e.puedePaginar) return;
    if (_scroll.position.maxScrollExtent <= 0) {
      context.read<SeguimientoBloc>().add(const SeguimientoPaginaSolicitada());
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;

    return Column(
      children: [
        LeadListFilterChips(
          filtroActual: e.filtro,
          conteos: e.conteos.comoMapa,
          onFiltroTap: (filtro) => context.read<SeguimientoBloc>().add(
            SeguimientoFiltroCambiado(filtro),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        LeadListStatsRow(conteos: e.conteos.comoMapa),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: e.recargandoLista
              ? const LeadCardSkeletonList()
              : e.items.isEmpty
              ? _VistaVacia(estado: e)
              : ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: e.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == e.items.length) {
                      return SeguimientoFooter(
                        estado: e,
                        onReintentar: () => context
                            .read<SeguimientoBloc>()
                            .add(const SeguimientoReintentarPagina()),
                      );
                    }
                    final lead = e.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LeadCard(
                        lead: lead,
                        onTap: () => context.goToDetalleContacto(
                          idContacto: lead.contacto.idContacto,
                        ),
                        onWhatsAppTap: () => context.goToDetalleChat(
                          idChatCab: lead.numero.idChatCab,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// 3 estados vacíos distintos, no uno genérico:
///  - contador en 0 → correcto, no hay casos en ese estado
///  - contador > 0 y lista vacía → NO es vacío, es un bug de consistencia: se
///    loguea y se muestra un mensaje neutro (pull-to-refresh).
class _VistaVacia extends StatelessWidget {
  final SeguimientoCargado estado;
  const _VistaVacia({required this.estado});

  @override
  Widget build(BuildContext context) {
    final conteo = estado.conteos.paraFiltro(estado.filtro);

    if (conteo > 0) {
      debugPrint(
        'Seguimiento: contador=$conteo pero lista vacía para ${estado.filtro} '
        '— inconsistencia contador/lista.',
      );
      return AppErrorView(
        message:
            'No se pudieron mostrar los casos. Desliza hacia abajo para volver a intentar.',
        onRetry: () => context.read<SeguimientoBloc>().add(
          const SeguimientoRefrescado(),
        ),
      );
    }

    // La búsqueda respeta chip + panel (el rango por defecto es el mes
    // actual), así que "sin resultados" puede ser por los filtros, no solo
    // por el texto — el mensaje lo dice.
    if (estado.busqueda.isNotEmpty) {
      return AppEmptyView(
        message:
            'Sin resultados para "${estado.busqueda}" con los filtros actuales.',
      );
    }

    final msg = switch (estado.filtro) {
      LeadListFiltro.todos => 'No tienes casos en seguimiento.',
      LeadListFiltro.nuevos => 'No tienes casos nuevos.',
      LeadListFiltro.enDesarrollo => 'No tienes casos en desarrollo.',
      LeadListFiltro.propuesta => 'No tienes casos en propuesta.',
    };
    return AppEmptyView(message: msg);
  }
}
