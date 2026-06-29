// lib/features/lead/presentation/widgets/contacto_detalle/contacto_detalle_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleView extends StatelessWidget {
  final int idContacto;

  const ContactoDetalleView({super.key, required this.idContacto});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactoDetalleBloc, ContactoDetalleState>(
      builder: (context, state) {
        if (state is ContactoDetalleInitial ||
            state is ContactoDetalleCargando) {
          return const ContactoDetalleSkeleton();
        }
        if (state is ContactoDetalleError) {
          return AppErrorView(
            message: state.mensaje,
            onRetry: () => context.read<ContactoDetalleBloc>().add(
              ContactoDetalleStarted(idContacto),
            ),
          );
        }
        if (state is ContactoDetalleCargado) {
          return _ContactoScaffold(
            contacto: state.contacto,
            negociaciones: state.negociaciones,
            idContacto: idContacto,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold real — datos cargados
// ─────────────────────────────────────────────────────────────────────────────

class _ContactoScaffold extends StatelessWidget {
  final ContactoDetalle contacto;
  final List<Negociacion> negociaciones;
  final int idContacto;

  const _ContactoScaffold({
    required this.contacto,
    required this.negociaciones,
    required this.idContacto,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BasePage(
        bodyPadding: EdgeInsets.zero,
        title: 'Detalle de contacto',
        drawerSide: DrawerSide.none,
        appBarLeadingButtons: [
          IconButton(
            icon: const Icon(AppIcons.backIos),
            onPressed: () => context.goBack(),
          ),
        ],
        footer: ContactoAccionesFooter(contacto: contacto),
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            final bloc = context.read<ContactoDetalleBloc>();
            bloc.add(ContactoDetalleStarted(idContacto));
            await bloc.stream.firstWhere(
              (s) => s is ContactoDetalleCargado || s is ContactoDetalleError,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ContactoDetalleHeader(contacto: contacto),
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
                  const Tab(text: 'Info'),
                  Tab(
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
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ContactoInfoTab(contacto: contacto),
                    ContactoNegociacionesTab(negociaciones: negociaciones),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
