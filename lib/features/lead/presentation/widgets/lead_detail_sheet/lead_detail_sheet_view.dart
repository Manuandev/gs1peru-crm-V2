// lib/features/lead/presentation/widgets/lead_detail_sheet/lead_detail_sheet_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class LeadDetailSheet extends StatefulWidget {
  final LeadDetailTab initialTab;
  final InfoLead infoLead;
  final int leadId;
  final int idNumero;

  const LeadDetailSheet({
    super.key,
    required this.initialTab,
    required this.infoLead,
    required this.leadId,
    required this.idNumero,
  });

  static Future<void> show(
    BuildContext context, {
    required LeadDetailTab initialTab,
    required InfoLead infoLead,
    required int leadId,
    int idNumero = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      useRootNavigator: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NegociacionesCubit()),
          BlocProvider(create: (_) => HistorialLeadCubit()),
        ],
        child: LeadDetailSheet(
          initialTab: initialTab,
          infoLead: infoLead,
          leadId: leadId,
          idNumero: idNumero,
        ),
      ),
    );
  }

  @override
  State<LeadDetailSheet> createState() => _LeadDetailSheetState();
}

class _LeadDetailSheetState extends State<LeadDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.40,
      maxChildSize: 0.95,
      builder: (sheetContext, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizing.radiusLg),
          ),
        ),
        child: Column(
          children: [
            const _DragHandle(),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(AppIcons.datosLead), text: 'Datos'),
                Tab(icon: Icon(AppIcons.negociacion), text: 'Negociaciones'),
                Tab(icon: Icon(AppIcons.historial), text: 'Historial'),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withValues(
                alpha: AppColors.opacityHint,
              ),
              indicatorColor: colorScheme.primary,
              labelStyle: AppTextStyles.labelMedium,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DatosTab(infoLead: widget.infoLead, idNumero: widget.idNumero),
                  NegociacionesTab(leadId: widget.leadId, idNumero: widget.idNumero),
                  HistorialTab(leadId: widget.leadId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pastillita de arrastre
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        width: AppSizing.handleWidth,
        height: AppSizing.dragHandleHeight,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
        ),
      ),
    );
  }
}
