// lib/features/lead/presentation/widgets/list/lead_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPortrait extends StatelessWidget {
  final List<Lead> leads;
  final LeadType type;
  final LeadListFiltro filtro;

  const LeadListPortrait({
    super.key,
    required this.leads,
    required this.type,
    required this.filtro,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Chips de filtro ────────────────────────────
        BlocBuilder<LeadListBloc, LeadListState>(
          buildWhen: (prev, curr) => curr is LeadListSuccess,
          builder: (context, state) {
            if (state is! LeadListSuccess) return const SizedBox.shrink();
            return LeadListFilterChips(
              filtroActual: state.filtro,
              conteos: state.conteos,
              onFiltroTap: (filtro) {
                context.read<LeadListBloc>().add(LeadListFiltered(filtro));
              },
              type: type,
            );
          },
        ),

        // ── Lista ──────────────────────────────────────
        Expanded(
          child: leads.isEmpty
              ? AppEmptyView(
                  message: switch (filtro) {
                    LeadListFiltro.todos =>
                      type == LeadType.seguimientos
                          ? 'No hay seguimientos.'
                          : 'No hay propuestas.',
                    LeadListFiltro.misCasos =>
                      type == LeadType.seguimientos
                          ? 'No tienes seguimientos asignados.'
                          : 'No tienes propuestas asignadas.',
                    LeadListFiltro.nuevos => 'No hay seguimientos nuevos.',
                    LeadListFiltro.enDesarrollo =>
                      'No hay seguimientos en desarrollo.',
                  },
                )
              : ListView.builder(
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LeadCard(
                        lead: lead,
                        onTap: () => context.goToDetalleLead(
                          idLead: lead.idLead,
                          type: type,
                        ),
                        onWhatsAppTap: () {},
                        onChatTap: () {},
                        onStarTap: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
