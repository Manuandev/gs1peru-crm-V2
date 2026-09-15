// lib/features/lead/presentation/widgets/lead_detail_sheet/tabs/recordatorios_tab.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Recordatorios futuros (SP 'LRN') de todos los leads del mismo contacto —
/// mismo patrón de carga que HistorialTab, sin chips de filtro.
class RecordatoriosTab extends StatefulWidget {
  final int idContacto;

  const RecordatoriosTab({super.key, required this.idContacto});

  @override
  State<RecordatoriosTab> createState() => _RecordatoriosTabState();
}

class _RecordatoriosTabState extends State<RecordatoriosTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    context.read<RecordatoriosLeadCubit>().cargarRecordatoriosPorContacto(
      widget.idContacto,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<RecordatoriosLeadCubit, RecordatoriosLeadState>(
      builder: (context, state) {
        return switch (state) {
          RecordatoriosLeadInitial() || RecordatoriosLeadLoading() =>
            const AppLoadingView(),
          RecordatoriosLeadError(:final mensaje) => AppErrorView(
            message: mensaje,
            onRetry: _cargar,
          ),
          RecordatoriosLeadSuccess(:final recordatorios) =>
            recordatorios.isEmpty
                ? const _EstadoVacio()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: recordatorios.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, index) =>
                        LeadRecordatorioCard(recordatorio: recordatorios[index]),
                  ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    // Mismo vacío que Historial (AppSeccionVacia), en azul para distinguirlo.
    // Con scroll para que no se desborde en paneles bajos.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Center(
            child: AppSeccionVacia(
              icono: AppIcons.recordatorio,
              color: AppColors.info,
              titulo: 'Sin recordatorios pendientes',
              mensaje: 'Este contacto no tiene recordatorios programados.',
            ),
          ),
        ),
      ),
    );
  }
}
