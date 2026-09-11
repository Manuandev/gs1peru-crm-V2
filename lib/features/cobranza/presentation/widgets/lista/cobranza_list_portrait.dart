// lib/features/cobranza/presentation/widgets/lista/cobranza_list_portrait.dart
//
// Lista paginada de Cobranzas (task 'LSP'). Tarjetas de estado + chips + scroll
// infinito con pie de página. Reusa CobranzaSummaryCards / CobranzaFilterChips /
// CobranzaCard sin tocarlos.

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListPortrait extends StatefulWidget {
  final CobranzaListCargado estado;

  const CobranzaListPortrait({super.key, required this.estado});

  @override
  State<CobranzaListPortrait> createState() => _CobranzaListPortraitState();
}

class _CobranzaListPortraitState extends State<CobranzaListPortrait> {
  final ScrollController _scroll = ScrollController();
  static const double _umbral = 0.8;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rellenarSiNoScrollea());
  }

  @override
  void didUpdateWidget(covariant CobranzaListPortrait old) {
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
      context.read<CobranzaListBloc>().add(const CobranzaPaginaSolicitada());
    }
  }

  void _rellenarSiNoScrollea() {
    if (!mounted || !_scroll.hasClients) return;
    final e = widget.estado;
    if (e.recargandoLista || e.items.isEmpty || !e.puedePaginar) return;
    if (_scroll.position.maxScrollExtent <= 0) {
      context.read<CobranzaListBloc>().add(const CobranzaPaginaSolicitada());
    }
  }

  Future<void> _onChipTap(CobranzaChipFiltro filtro) async {
    final bloc = context.read<CobranzaListBloc>();
    if (filtro != CobranzaChipFiltro.asesores) {
      bloc.add(CobranzaChipChanged(filtro));
      return;
    }
    final codAsesor = await CobranzaAsesorPickerModal.show(
      context,
      conteosPorAsesor: widget.estado.conteosPorAsesor,
      seleccionadoActual: widget.estado.asesorSeleccionado,
    );
    if (codAsesor == null) {
      bloc.add(const CobranzaChipChanged(CobranzaChipFiltro.todos));
    } else {
      bloc.add(CobranzaAsesorSeleccionado(codAsesor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;

    return Column(
      children: [
        CobranzaSummaryCards(
          conteosPorEstado: e.conteos.porEstado,
          estadosSeleccionados: e.estadosSeleccionados,
          onEstadoTap: (idEstado) => context
              .read<CobranzaListBloc>()
              .add(CobranzaEstadoToggled(idEstado)),
        ),
        CobranzaFilterChips(
          filtroActual: e.chipFiltro,
          onFiltroTap: _onChipTap,
        ),
        Expanded(
          child: e.recargandoLista
              ? const AppLoadingView()
              : e.items.isEmpty
              ? AppEmptyView(message: _mensajeVacio(e))
              : ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: e.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == e.items.length) {
                      return _CobranzaFooter(
                        estado: e,
                        onReintentar: () => context
                            .read<CobranzaListBloc>()
                            .add(const CobranzaReintentarPagina()),
                      );
                    }
                    final cobranza = e.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: CobranzaCard(
                        cobranza: cobranza,
                        onTap: () => context.goToDetalleCobranza(
                          numSol: cobranza.numSol,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _mensajeVacio(CobranzaListCargado e) {
    // La búsqueda respeta chip + tarjetas + panel: "sin resultados" puede ser
    // por los filtros, no solo por el texto.
    if (e.busqueda.isNotEmpty) {
      return 'Sin resultados para "${e.busqueda}" con los filtros actuales.';
    }
    if (e.chipFiltro == CobranzaChipFiltro.asesores) {
      return 'Este asesor no tiene cobranzas asignadas.';
    }
    if (e.chipFiltro == CobranzaChipFiltro.contado) {
      return 'No hay cobranzas al contado.';
    }
    if (e.chipFiltro == CobranzaChipFiltro.credito) {
      return 'No hay cobranzas a crédito.';
    }
    if (e.filtroAvanzado.activo || e.estadosSeleccionados.isNotEmpty) {
      return 'No hay cobranzas para el filtro seleccionado.';
    }
    return 'No hay cobranzas registradas.';
  }
}

/// Pie de la lista: spinner mientras carga la página siguiente, error +
/// "Reintentar" si falló, o "Fin de la lista" cuando ya no hay más.
class _CobranzaFooter extends StatelessWidget {
  final CobranzaListCargado estado;
  final VoidCallback onReintentar;

  const _CobranzaFooter({required this.estado, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    if (estado.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Text(
              estado.loadMoreError!,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            CustomTextButton(text: 'Reintentar', onPressed: onReintentar),
          ],
        ),
      );
    }

    if (estado.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeSmall,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (estado.finLista && estado.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Text(
            '· Fin de la lista ·',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: AppSpacing.md);
  }
}
