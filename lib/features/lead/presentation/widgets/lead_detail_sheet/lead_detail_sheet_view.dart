// lib/features/lead/presentation/widgets/lead_detail_sheet/lead_detail_sheet_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetailSheet extends StatefulWidget {
  final LeadDetailTab initialTab;
  final Lead lead;
  final int leadId;
  final int idNumero;
  final InfoLeadCubit? cubit;

  const LeadDetailSheet({
    super.key,
    required this.initialTab,
    required this.lead,
    required this.leadId,
    required this.idNumero,
    this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    required LeadDetailTab initialTab,
    required Lead lead,
    required int leadId,
    int idNumero = 0,
    InfoLeadCubit? cubit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      useRootNavigator: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => NegociacionesCubit(
              obtenerNegociacionesUseCase:
                  GetNegociacionesLead(LeadRepositoryImpl(LeadRemoteDatasource())),
            ),
          ),
          BlocProvider(create: (_) => HistorialLeadCubit()),
        ],
        child: LeadDetailSheet(
          initialTab: initialTab,
          lead: lead,
          leadId: leadId,
          idNumero: idNumero,
          cubit: cubit,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        // Si hay cubit, escucha cambios en tiempo real (edición de lead, WebSocket).
        // Si no, usa el lead estático recibido al abrir el sheet.
        if (widget.cubit != null) {
          return BlocBuilder<InfoLeadCubit, InfoLeadState>(
            bloc: widget.cubit,
            buildWhen: (prev, curr) => curr is InfoLeadSuccess,
            builder: (context, state) {
              final lead = state is InfoLeadSuccess ? state.lead : widget.lead;
              return _SheetContent(
                lead: lead,
                leadId: widget.leadId,
                idNumero: widget.idNumero,
                cubit: widget.cubit,
                tabController: _tabController,
              );
            },
          );
        }
        return _SheetContent(
          lead: widget.lead,
          leadId: widget.leadId,
          idNumero: widget.idNumero,
          cubit: widget.cubit,
          tabController: _tabController,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenido visual del sheet — separado para poder reconstruirlo con BlocBuilder
// ─────────────────────────────────────────────────────────────────────────────

class _SheetContent extends StatelessWidget {
  final Lead lead;
  final int leadId;
  final int idNumero;
  final InfoLeadCubit? cubit;
  final TabController tabController;

  const _SheetContent({
    required this.lead,
    required this.leadId,
    required this.idNumero,
    required this.cubit,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // ── Handle ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              width: AppSizing.sheetHandleWidth,
              height: AppSizing.sheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusMd,
                  backgroundColor: lead.nombreCompleto.avatarColor,
                  child: Text(
                    lead.nombreCompleto.initials,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.nombreCompleto,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lead.nombreEmpresa.isNotEmpty)
                        Text(
                          lead.nombreEmpresa,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Tabs ──
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(icon: Icon(AppIcons.datosLead), text: 'Datos'),
              Tab(icon: Icon(AppIcons.negociacion), text: 'Negociaciones'),
              Tab(icon: Icon(AppIcons.historial), text: 'Historial'),
            ],
          ),

          // ── Contenido ──
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                DatosTab(lead: lead, idNumero: idNumero, cubit: cubit),
                NegociacionesTab(leadId: leadId, idNumero: idNumero),
                HistorialTab(leadId: leadId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
