// lib/features/cobranza/presentation/widgets/lista/cobranza_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListPortrait extends StatelessWidget {
  final List<Cobranza> cobranzas;
  final CobranzaChipFiltro chipFiltro;
  final Set<int> estadosSeleccionados;
  final String? asesorSeleccionado;
  final Map<String, int> conteosPorAsesor;

  const CobranzaListPortrait({
    super.key,
    required this.cobranzas,
    required this.chipFiltro,
    required this.estadosSeleccionados,
    this.asesorSeleccionado,
    this.conteosPorAsesor = const {},
  });

  Future<void> _onFiltroTap(BuildContext context, CobranzaChipFiltro filtro) async {
    final bloc = context.read<CobranzaListBloc>();

    if (filtro != CobranzaChipFiltro.asesores) {
      bloc.add(CobranzaChipChanged(filtro));
      return;
    }

    final codAsesor = await CobranzaAsesorPickerModal.show(
      context,
      conteosPorAsesor: conteosPorAsesor,
      seleccionadoActual: asesorSeleccionado,
    );

    if (codAsesor == null) {
      bloc.add(const CobranzaChipChanged(CobranzaChipFiltro.todos));
    } else {
      bloc.add(CobranzaAsesorSeleccionado(codAsesor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Chips de filtro ────────────────────────────
        BlocBuilder<CobranzaListBloc, CobranzaListState>(
          buildWhen: (prev, curr) => curr is CobranzaListSuccess,
          builder: (context, state) {
            if (state is! CobranzaListSuccess) return const SizedBox.shrink();
            return CobranzaFilterChips(
              filtroActual: state.chipFiltro,
              onFiltroTap: (filtro) => _onFiltroTap(context, filtro),
            );
          },
        ),

        // ── Lista ──────────────────────────────────────
        Expanded(
          child: cobranzas.isEmpty
              ? AppEmptyView(message: _mensajeVacio())
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: cobranzas.length,
                  itemBuilder: (context, index) {
                    final cobranza = cobranzas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: CobranzaCard(
                        cobranza: cobranza,
                        onVerTap: () => context.goToDetalleCobranza(
                          numSol: cobranza.numSol,
                        ),
                        // onWhatsAppTap: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _mensajeVacio() {
    if (chipFiltro == CobranzaChipFiltro.asesores) {
      return 'Este asesor no tiene cobranzas asignadas.';
    }
    if (chipFiltro == CobranzaChipFiltro.contado) {
      return 'No hay cobranzas al contado.';
    }
    if (chipFiltro == CobranzaChipFiltro.credito) {
      return 'No hay cobranzas a crédito.';
    }
    return 'No hay cobranzas registradas.';
  }
}
