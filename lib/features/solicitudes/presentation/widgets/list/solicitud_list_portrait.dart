// lib/features/solicitudes/presentation/widgets/list/solicitud_list_portrait.dart
//
// Lista paginada de Solicitudes: chips + scroll infinito + pie de página.
// Al cambiar de chip / aplicar filtro (recargandoLista), chips quedan montados
// y solo el área de la lista muestra el skeleton de cards.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListPortrait extends StatefulWidget {
  final SolicitudListSuccess estado;

  const SolicitudListPortrait({super.key, required this.estado});

  @override
  State<SolicitudListPortrait> createState() => _SolicitudListPortraitState();
}

class _SolicitudListPortraitState extends State<SolicitudListPortrait> {
  final ScrollController _scroll = ScrollController();
  static const double _umbral = 0.8;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rellenarSiNoScrollea());
  }

  @override
  void didUpdateWidget(covariant SolicitudListPortrait old) {
    super.didUpdateWidget(old);
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
      context.read<SolicitudListBloc>().add(const SolicitudPaginaSolicitada());
    }
  }

  void _rellenarSiNoScrollea() {
    if (!mounted || !_scroll.hasClients) return;
    final e = widget.estado;
    if (e.recargandoLista || e.solicitudes.isEmpty || !e.puedePaginar) return;
    if (_scroll.position.maxScrollExtent <= 0) {
      context.read<SolicitudListBloc>().add(const SolicitudPaginaSolicitada());
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;

    return Column(
      children: [
        SolicitudFilterChips(
          filtroActual: e.filtro,
          onFiltroTap: (f) async {
            final bloc = context.read<SolicitudListBloc>();
            if (f != SolicitudFiltro.asesores) {
              bloc.add(SolicitudListFiltered(f));
              return;
            }
            final seleccionado = await SolicitudAsesorPickerModal.show(
              context,
              conteosPorAsesor: e.conteosPorAsesor,
              seleccionadoActual: e.asesorSeleccionado,
            );
            if (!context.mounted) return;
            if (seleccionado != null) {
              bloc.add(SolicitudListAsesorSeleccionado(seleccionado));
            } else {
              bloc.add(const SolicitudListFiltered(SolicitudFiltro.todas));
            }
          },
        ),
        Expanded(
          child: e.recargandoLista
              ? const SolicitudCardSkeletonList()
              : e.solicitudes.isEmpty
              ? AppEmptyView(
                  // La búsqueda respeta chip + panel: "sin resultados" puede
                  // ser por los filtros, no solo por el texto.
                  message: e.busqueda.isNotEmpty
                      ? 'Sin resultados para "${e.busqueda}" con los filtros actuales.'
                      : switch (e.filtro) {
                          SolicitudFiltro.todas => 'No hay solicitudes.',
                          SolicitudFiltro.asesores =>
                            'No tienes solicitudes asignadas.',
                          SolicitudFiltro.sinValidar =>
                            'No hay solicitudes pendientes de validación.',
                          SolicitudFiltro.enviarACobranza =>
                            'No hay solicitudes validadas.',
                        },
                )
              : ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxs,
                  ),
                  itemCount: e.solicitudes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == e.solicitudes.length) {
                      return SolicitudFooter(
                        estado: e,
                        onReintentar: () => context
                            .read<SolicitudListBloc>()
                            .add(const SolicitudReintentarPagina()),
                      );
                    }
                    final s = e.solicitudes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SolicitudCard(
                        solicitud: s,
                        onVer: () => context.goToDetalleSolicitud(solicitud: s),
                        onAccion: () => context.goToDetalleSolicitud(
                          solicitud: s,
                          origenValidar: true,
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
