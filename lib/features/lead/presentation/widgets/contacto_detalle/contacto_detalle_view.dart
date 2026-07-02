// lib/features/lead/presentation/widgets/contacto_detalle/contacto_detalle_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleView extends StatefulWidget {
  final int idLead;

  const ContactoDetalleView({super.key, required this.idLead});

  @override
  State<ContactoDetalleView> createState() => _ContactoDetalleViewState();
}

class _ContactoDetalleViewState extends State<ContactoDetalleView> {
  @override
  void initState() {
    super.initState();
    context.read<InfoLeadCubit>().load(widget.idLead);
    context.read<NegociacionesCubit>().cargarNegociaciones(widget.idLead);
  }

  Future<void> _refrescar() => Future.wait([
    context.read<InfoLeadCubit>().load(widget.idLead),
    context.read<NegociacionesCubit>().cargarNegociaciones(widget.idLead),
  ]);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoLeadCubit, InfoLeadState>(
      builder: (context, state) {
        if (state is InfoLeadInitial || state is InfoLeadLoading) {
          return const ContactoDetalleSkeleton();
        }
        if (state is InfoLeadFailure) {
          return BasePage(
            title: 'Detalle de contacto',
            drawerSide: DrawerSide.none,
            appBarLeadingButtons: [
              IconButton(
                icon: const Icon(AppIcons.backIos),
                onPressed: () => context.goBack(),
              ),
            ],
            body: AppErrorView(
              message: state.message,
              onRetry: () => context.read<InfoLeadCubit>().load(widget.idLead),
            ),
          );
        }
        final lead = (state as InfoLeadSuccess).lead;
        return _ContactoScaffold(lead: lead, onRefresh: _refrescar);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold real — datos cargados
// ─────────────────────────────────────────────────────────────────────────────

class _ContactoScaffold extends StatelessWidget {
  final Lead lead;
  final Future<void> Function() onRefresh;

  const _ContactoScaffold({required this.lead, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BasePage(
        bodyPadding: EdgeInsets.zero,
        titleWidget: _ContactoHeaderTitle(lead: lead),
        drawerSide: DrawerSide.none,
        appBarLeadingButtons: [
          IconButton(
            icon: const Icon(AppIcons.backIos),
            onPressed: () => context.goBack(),
          ),
        ],
        footer: ContactoAccionesFooter(lead: lead),
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChatDetailFases(
                idEstadoActual: lead.idEstado,
                idEstadoPadre: lead.idEstadoPadre ?? '',
              ),
              BlocBuilder<NegociacionesCubit, NegociacionesState>(
                builder: (context, negState) {
                  final negociaciones = negState is NegociacionesSuccess
                      ? negState.negociaciones
                      : const <Negociacion>[];

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TabBar(
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: AppSizing.borderFocusWidth,
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: AppColors.transparent,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.weightBold,
                          ),
                          unselectedLabelStyle: AppTextStyles.labelLarge,
                          tabs: [
                            const Tab(
                              icon: Icon(AppIcons.datosLead, size: AppSizing.iconSm),
                              text: 'Información',
                            ),
                            Tab(
                              icon: const Icon(
                                AppIcons.negociacion,
                                size: AppSizing.iconSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Negociaciones'),
                                  if (negociaciones.isNotEmpty) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    _ContadorBadge(count: negociaciones.length),
                                  ],
                                ],
                              ),
                            ),
                            const Tab(
                              icon: Icon(AppIcons.historial, size: AppSizing.iconSm),
                              text: 'Historial',
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ContactoInfoTab(
                                lead: lead,
                                negociaciones: negociaciones,
                              ),
                              ContactoNegociacionesTab(
                                negociaciones: negociaciones,
                              ),
                              HistorialTab(idNumero: lead.idNumero),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Título del AppBar — avatar con badge de estado + nombre
// ─────────────────────────────────────────────────────────────────────────────

class _ContactoHeaderTitle extends StatelessWidget {
  final Lead lead;

  const _ContactoHeaderTitle({required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: AppSizing.avatarRadiusAppBar,
              backgroundColor: AvatarUtils.color(lead.nombreCompleto),
              child: Text(
                AvatarUtils.initials(lead.nombreCompleto),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: AppSizing.avatarCanalBadge,
                height: AppSizing.avatarCanalBadge,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: AppSizing.canalBadgeBorder,
                  ),
                ),
                child: Center(
                  child: AppSocialUtils.widgetEstado(
                    lead.idEstadoEfectivo,
                    size: AppSizing.iconCanalBadge,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.smPlus),
        Expanded(
          child: Text(
            lead.nombreCompleto,
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: AppTextStyles.weightBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ContadorBadge extends StatelessWidget {
  final int count;

  const _ContadorBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textOnDark,
          fontWeight: AppTextStyles.weightBold,
        ),
      ),
    );
  }
}
