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
        // ── Tabs de filtro ────────────────────────────────────────
        BlocBuilder<SolicitudListBloc, SolicitudListState>(
          buildWhen: (_, curr) => curr is SolicitudListSuccess,
          builder: (context, state) {
            if (state is! SolicitudListSuccess) return const SizedBox.shrink();
            return _SolicitudFilterTabs(
              filtroActual: state.filtro,
              onFiltroTap: (f) => context.read<SolicitudListBloc>().add(
                SolicitudListFiltered(f),
              ),
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
                      'No hay solicitudes listas para cobranza.',
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

// ─── Chips de filtro ──────────────────────────────────────────────────────────

class _SolicitudFilterTabs extends StatelessWidget {
  final SolicitudFiltro filtroActual;
  final void Function(SolicitudFiltro) onFiltroTap;

  const _SolicitudFilterTabs({
    required this.filtroActual,
    required this.onFiltroTap,
  });

  static const _opciones = [
    (SolicitudFiltro.todas, 'Todas'),
    (SolicitudFiltro.asesores, 'Asesores'),
    (SolicitudFiltro.sinValidar, 'Sin validar'),
    (SolicitudFiltro.enviarACobranza, 'Enviar a cobranza'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: _opciones.map((entry) {
            final (filtro, label) = entry;
            final seleccionado = filtroActual == filtro;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onFiltroTap(filtro),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.primary
                        : AppColors.grey300.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(
                      AppSizing.radiusCircular,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: seleccionado
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                      fontWeight: seleccionado
                          ? AppTextStyles.weightSemiBold
                          : AppTextStyles.weightRegular,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
