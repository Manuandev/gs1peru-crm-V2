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
                  ObtenerNegociacionesUseCase(LeadRepositoryImpl(LeadRemoteDatasource())),
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
                      backgroundColor: widget.lead.nombreCompleto.avatarColor,
                      child: Text(
                        widget.lead.nombreCompleto.initials,
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
                            widget.lead.nombreCompleto,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: AppTextStyles.weightBold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.lead.nombreEmpresa.isEmpty
                                ? 'Sin empresa'
                                : widget.lead.nombreEmpresa,
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
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Datos'),
                  Tab(text: 'Negociaciones'),
                  Tab(text: 'Historial'),
                ],
              ),

              // ── Contenido ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    DatosTab(lead: widget.lead, idNumero: widget.idNumero, cubit: widget.cubit),
                    NegociacionesTab(leadId: widget.leadId, idNumero: widget.idNumero),
                    HistorialTab(leadId: widget.leadId),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
