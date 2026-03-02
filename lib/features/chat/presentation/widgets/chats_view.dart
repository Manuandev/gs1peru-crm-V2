import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/core/utils/responsive_helper.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_bloc.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_event.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_state.dart';
import 'package:app_crm/features/chat/presentation/widgets/chats_landscape.dart';
import 'package:app_crm/features/chat/presentation/widgets/chats_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/core/presentation/pages/base_page.dart';
import 'package:app_crm/core/presentation/widgets/navigation/drawer_item_model.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Chats',
      drawerSide: DrawerSide.left,
      onSearch: (query) {
        context.read<ChatsBloc>().add(ChatsSearchRequested(query));
      },
      appBarPopupItems: const [
        AppBarPopupItem(
          value: 'refresh',
          icon: AppIcons.refresh,
          label: 'Actualizar',
        ),
      ],
      onPopupSelected: (value) {
        switch (value) {
          case 'refresh':
            context.read<ChatsBloc>().add(ChatsRefreshRequested());
        }
      },
      // appBarTrailingButtons: [
      //   IconButton(
      //     icon: Icon(AppIcons.refresh, color: AppColors.textOnDark),
      //     onPressed: () {
      //       context.read<ChatsBloc>().add(ChatsRefreshRequested());
      //     },
      //   ),
      // ],
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          if (state is ChatsLoading || state is ChatsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatsError) {
            return _ChatsError(
              message: state.message,
              onRetry: () {
                context.read<ChatsBloc>().add(ChatsRefreshRequested());
              },
            );
          }

          if (state is ChatsLoaded) {
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return ChatsLandscape(state: state);
                }
                return ChatsPortrait(state: state);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Widget de error ───────────────────────────────────────────────
class _ChatsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChatsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorIconSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 64,
      tablet: 72,
      desktop: 80,
    );
    final errorTextSize = ResponsiveHelper.getValue<double>(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: errorIconSize,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: errorTextSize,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
