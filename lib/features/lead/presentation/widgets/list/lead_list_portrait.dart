// lib/features/lead/presentation/widgets/list/lead_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPortrait extends StatefulWidget {
  final List<Lead> leads;
  final LeadListFiltro filtro;

  const LeadListPortrait({
    super.key,
    required this.leads,
    required this.filtro,
  });

  @override
  State<LeadListPortrait> createState() => _LeadListPortraitState();
}

class _LeadListPortraitState extends State<LeadListPortrait> {
  LeadListOrden _orden = LeadListOrden.ultimaInteraccion;

  List<Lead> get _leadsOrdenados {
    final leads = List<Lead>.from(widget.leads);
    switch (_orden) {
      case LeadListOrden.ultimaInteraccion:
        leads.sort((a, b) {
          final fa = DateFormatter.parseDate(a.fechaHora) ?? DateTime(0);
          final fb = DateFormatter.parseDate(b.fechaHora) ?? DateTime(0);
          return fb.compareTo(fa);
        });
      case LeadListOrden.nombreAZ:
        leads.sort(
          (a, b) => a.nombreCompleto.toLowerCase().compareTo(
                b.nombreCompleto.toLowerCase(),
              ),
        );
    }
    return leads;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Chips de filtro ────────────────────────────
        BlocBuilder<LeadListBloc, LeadListState>(
          buildWhen: (prev, curr) => curr is LeadListSuccess,
          builder: (context, state) {
            if (state is! LeadListSuccess) return const SizedBox.shrink();
            return Column(
              children: [
                LeadListFilterChips(
                  filtroActual: state.filtro,
                  conteos: state.conteos,
                  onFiltroTap: (filtro) {
                    context.read<LeadListBloc>().add(LeadListFiltered(filtro));
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                LeadListStatsRow(conteos: state.conteos),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        ),

        LeadListOrdenDropdown(
          ordenActual: _orden,
          onChanged: (o) => setState(() => _orden = o),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Lista ──────────────────────────────────────
        Expanded(
          child: widget.leads.isEmpty
              ? AppEmptyView(
                  message: switch (widget.filtro) {
                    LeadListFiltro.todos => 'No hay seguimientos.',
                    LeadListFiltro.misCasos =>
                      'No tienes seguimientos asignados.',
                    LeadListFiltro.nuevos => 'No hay seguimientos nuevos.',
                    LeadListFiltro.enDesarrollo =>
                      'No hay seguimientos en desarrollo.',
                    LeadListFiltro.propuesta =>
                      'No hay seguimientos listos para propuesta.',
                  },
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _leadsOrdenados.length,
                  itemBuilder: (context, index) {
                    final lead = _leadsOrdenados[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LeadCard(
                        lead: lead,
                        onTap: () => context.goToDetalleContacto(
                          idContacto: lead.idContacto,
                        ),
                        onWhatsAppTap: () {},
                        onChatTap: () {},
                        onStarTap: () => context.read<LeadListBloc>().add(
                              ToggleFavoritoPressed(
                                idLead: lead.idLead,
                                nuevoValor: !lead.isFavorito,
                              ),
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
