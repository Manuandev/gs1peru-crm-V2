// lib/features/cobranza/presentation/widgets/cobranza_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListPortrait extends StatelessWidget {
  final List<Cobranza> cobranzas;
  final CobranzaChipFiltro chipFiltro;
  final Set<String> estadosSeleccionados;

  const CobranzaListPortrait({
    super.key,
    required this.cobranzas,
    required this.chipFiltro,
    required this.estadosSeleccionados,
  });

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
              onFiltroTap: (filtro) => context.read<CobranzaListBloc>().add(
                CobranzaChipChanged(filtro),
              ),
            );
          },
        ),

        // ── Lista ──────────────────────────────────────
        Expanded(
          child: cobranzas.isEmpty
              ? AppEmptyView(message: _mensajeVacio())
              : ListView.builder(
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
                        onWhatsAppTap: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _mensajeVacio() {
    if (chipFiltro == CobranzaChipFiltro.misCasos) {
      return 'No tienes cobranzas asignadas.';
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
