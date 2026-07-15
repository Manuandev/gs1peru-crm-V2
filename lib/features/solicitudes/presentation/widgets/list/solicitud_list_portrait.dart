// lib/features/solicitudes/presentation/widgets/list/solicitud_list_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListPortrait extends StatelessWidget {
  final List<Solicitud> solicitudes;
  final SolicitudFiltro filtro;

  const SolicitudListPortrait({
    super.key,
    required this.solicitudes,
    required this.filtro,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Chips de filtro ────────────────────────────────────────
        BlocBuilder<SolicitudListBloc, SolicitudListState>(
          buildWhen: (_, curr) => curr is SolicitudListSuccess,
          builder: (context, state) {
            if (state is! SolicitudListSuccess) return const SizedBox.shrink();
            return SolicitudFilterChips(
              filtroActual: state.filtro,
              onFiltroTap: (f) async {
                final bloc = context.read<SolicitudListBloc>();

                if (f != SolicitudFiltro.asesores) {
                  bloc.add(SolicitudListFiltered(f));
                  return;
                }

                final seleccionado = await SolicitudAsesorPickerModal.show(
                  context,
                  conteosPorAsesor: state.conteosPorAsesor,
                  seleccionadoActual: state.asesorSeleccionado,
                );

                if (!context.mounted) return;
                if (seleccionado != null) {
                  bloc.add(SolicitudListAsesorSeleccionado(seleccionado));
                } else {
                  bloc.add(const SolicitudListFiltered(SolicitudFiltro.todas));
                }
              },
            );
          },
        ),

        // ── Lista ─────────────────────────────────────────────────
        Expanded(
          child: solicitudes.isEmpty
              ? AppEmptyView(
                  message: switch (filtro) {
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxs,
                  ),
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final s = solicitudes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SolicitudCard(
                        solicitud: s,
                        onVer: () =>
                            context.goToDetalleSolicitud(solicitud: s),
                        onAccion: () =>
                            context.goToDetalleSolicitud(solicitud: s),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
