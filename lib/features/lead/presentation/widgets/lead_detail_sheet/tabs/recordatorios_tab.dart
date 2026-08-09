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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSizing.radiusXl),
              ),
              child: const Icon(
                AppIcons.recordatorio,
                size: AppSizing.iconXl,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin recordatorios',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No hay recordatorios pendientes para este contacto.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
