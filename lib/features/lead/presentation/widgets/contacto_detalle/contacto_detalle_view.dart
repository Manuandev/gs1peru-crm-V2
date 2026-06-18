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
  final List<Lead> negociaciones;
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
        appBarTrailingButtons: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            color: AppColors.textOnDark,
            onPressed: () => context.read<ContactoDetalleBloc>().add(
              ContactoDetalleStarted(idContacto),
            ),
          ),
        ],
        footer: ContactoAccionesFooter(contacto: contacto),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContactoDetalleHeader(contacto: contacto),
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.white(
                  AppColors.opacityOnPrimarySubtle,
                ),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium,
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
