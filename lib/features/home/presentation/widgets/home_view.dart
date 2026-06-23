// lib/features/home/presentation/widgets/home_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onLogout: () => context.logoutWithConfirmation(context),
      // Logo GS1 + "CRM Perú" igual que el header del drawer
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppImages.logoGs1PeruBlanco, height: AppSizing.avatarSm * 0.65),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'CRM Perú',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
        ],
      ),
      drawerSide: DrawerSide.left,
      appBarTrailingButtons: [
        // ── Notificaciones con badge ───────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(AppIcons.notification, color: AppColors.textOnDark),
              onPressed: () => context.goToNotifications(),
            ),
            Positioned(
              top: AppSpacing.chipGap,
              right: AppSpacing.chipGap,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is! HomeLoaded) return const SizedBox.shrink();

                  final count = state.totNotificaciones;
                  if (count == 0) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.badgePadding),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: AppSizing.iconSm,
                      minHeight: AppSizing.iconSm,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: AppTextStyles.sizeXxs,
                        fontWeight: AppTextStyles.weightBold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
      // Sin padding para que el header azul llegue hasta los bordes
      bodyPadding: EdgeInsets.zero,
      showBottomNav: true,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          final bloc = context.read<HomeBloc>();
          bloc.add(HomeRefresh());
          await bloc.stream
              .firstWhere((s) => s is HomeLoaded || s is HomeError);
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading) {
              return const AppLoadingView();
            }

            if (state is HomeError) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<HomeBloc>().add(HomeRefresh()),
              );
            }

            if (state is HomeLoaded) {
              return HomePortrait(state: state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

