// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/historial_tab.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class HistorialTab extends StatefulWidget {
  // Historial unificado (SP 'LHC': seguimiento + comentario + recordatorio)
  // de TODAS las negociaciones activas del contacto — mismo llamado en
  // Seguimiento (ContactoDetalleView) y Conversaciones (ChatLeadPanel).
  // El ítem es AppHistorialEventoItem (core), el mismo que usan los
  // Detalles de Solicitud y de cobro.
  final int idContacto;

  const HistorialTab({super.key, required this.idContacto});

  @override
  State<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<HistorialTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // null = Todos
  TipoActor? _filtro;

  StreamSubscription<LeadUpdate>? _updateSub;

  @override
  void initState() {
    super.initState();
    _cargar();

    // Crear/editar una negociación escribe una fila en T_LEAD_SEGUIMIENTO
    // ("Negociación creada/editada"). Sin esto, el historial se quedaba con
    // lo que trajo al abrir la pantalla hasta salir y volver a entrar.
    // Recarga en silencio (no pierde la lista actual). Vale igual para
    // ContactoDetalle (Seguimiento) y ChatLeadPanel (Conversaciones).
    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final n = update.updatedLead;
      if (!mounted || n is! Negociacion) return;
      if (n.idContacto != widget.idContacto) return;
      context.read<HistorialLeadCubit>().cargarHistorialPorContacto(
        widget.idContacto,
        silencioso: true,
      );
    });
  }

  @override
  void dispose() {
    _updateSub?.cancel();
    super.dispose();
  }

  void _cargar() {
    context.read<HistorialLeadCubit>().cargarHistorialPorContacto(
      widget.idContacto,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HistorialLeadCubit, HistorialLeadState>(
      builder: (context, state) {
        return switch (state) {
          HistorialLeadInitial() || HistorialLeadLoading() =>
            const AppLoadingView(),
          HistorialLeadError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: _cargar,
          ),
          // Los chips de filtro siempre se muestran, incluso sin eventos —
          // solo lo de abajo cambia entre lista y estado vacío.
          HistorialLeadSuccess(:final eventos) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHistorialFiltroChips(
                filtroSeleccionado: _filtro,
                onFiltroChanged: (f) => setState(() => _filtro = f),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              Expanded(
                child: eventos.isEmpty
                    ? const _EstadoVacio()
                    : _ListaHistorial(
                        eventos: eventos.filtrarPorActor(_filtro),
                      ),
              ),
            ],
          ),
        };
      },
    );
  }
}

class _ListaHistorial extends StatelessWidget {
  final List<HistorialComentario> eventos;

  const _ListaHistorial({required this.eventos});

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) return const AppHistorialSinResultados();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      itemCount: eventos.length,
      itemBuilder: (_, index) => AppHistorialEventoItem(
        evento: eventos[index],
        mostrarOportunidad: true,
        esUltimo: index == eventos.length - 1,
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    // Mismo vacío que el Historial del Detalle de Solicitud (AppSeccionVacia).
    // Con scroll: el panel del chat es bajo y, sin esto, el contenido se
    // desbordaba ("BOTTOM OVERFLOWED").
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Center(
            child: AppSeccionVacia(
              icono: AppIcons.historial,
              color: AppColors.warning,
              titulo: 'Sin movimientos registrados',
              mensaje:
                  'Este contacto aún no registra movimientos en sus '
                  'negociaciones.',
            ),
          ),
        ),
      ),
    );
  }
}
