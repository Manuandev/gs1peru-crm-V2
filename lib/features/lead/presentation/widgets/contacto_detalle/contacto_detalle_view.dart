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
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardSection(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: ChatDetailFases(
                  idEstadoActual: lead.idEstado,
                  idEstadoPadre: lead.idEstadoPadre ?? '',
                ),
              ),
              _CardSection(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: TabBar(
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
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                  tabs: const [
                    Tab(
                      icon: Icon(AppIcons.datosLead, size: AppSizing.iconXs),
                      text: 'Información',
                    ),
                    Tab(
                      icon: Icon(AppIcons.negociacion, size: AppSizing.iconXs),
                      text: 'Negociaciones',
                    ),
                    Tab(
                      icon: Icon(AppIcons.historial, size: AppSizing.iconXs),
                      text: 'Historial',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<NegociacionesCubit, NegociacionesState>(
                  builder: (context, negState) {
                    final negociaciones = negState is NegociacionesSuccess
                        ? negState.negociaciones
                        : const <Negociacion>[];

                    return TabBarView(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card flotante — envuelve stepper y tab bar sobre el fondo gris de la página
// ─────────────────────────────────────────────────────────────────────────────

class _CardSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _CardSection({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, AppSizing.shadowOffsetCardY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: ColoredBox(color: AppColors.surface, child: child),
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
