// lib/features/lead/presentation/widgets/list/lead_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPortrait extends StatelessWidget {
  final List<Lead> leads;
  final LeadListFiltro filtro;

  const LeadListPortrait({
    super.key,
    required this.leads,
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
            return Column(
              children: [
                LeadListFilterChips(
                  filtroActual: state.filtro,
                  conteos: state.conteos,
                  onFiltroTap: (filtro) async {
                    final bloc = context.read<LeadListBloc>();

                    if (filtro != LeadListFiltro.asesores) {
                      bloc.add(LeadListFiltered(filtro));
                      return;
                    }

                    final seleccionado = await LeadAsesorPickerModal.show(
                      context,
                      conteosPorAsesor: state.conteosPorAsesor,
                      seleccionadoActual: state.asesorSeleccionado,
                    );

                    if (!context.mounted) return;
                    if (seleccionado != null) {
                      bloc.add(LeadListAsesorSeleccionado(seleccionado));
                    } else {
                      bloc.add(const LeadListFiltered(LeadListFiltro.todos));
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                LeadListStatsRow(conteos: state.conteos),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        ),

        // ── Lista ──────────────────────────────────────
        Expanded(
          child: leads.isEmpty
              ? AppEmptyView(
                  message: switch (filtro) {
                    LeadListFiltro.todos => 'No hay seguimientos.',
                    LeadListFiltro.asesores =>
                      'Este asesor no tiene seguimientos asignados.',
                    LeadListFiltro.nuevos => 'No hay seguimientos nuevos.',
                    LeadListFiltro.enDesarrollo =>
                      'No hay seguimientos en gestión.',
                    LeadListFiltro.propuesta =>
                      'No hay seguimientos listos para propuesta.',
                  },
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LeadCard(
                        lead: lead,
                        onTap: () =>
                            context.goToDetalleContacto(idLead: lead.idLead),
                        onWhatsAppTap: () => context.goToDetalleChat(
                          idChatCab: lead.idChatCab,
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
