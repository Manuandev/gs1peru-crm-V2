// lib/config/router/navigation_extensions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/chat/index_chat.dart';

extension NavigationExtensions on BuildContext {
  // ── Primitivos (no usar directamente desde features) ───────

  Future<T?> _push<T>(String routeName, {Object? arguments}) {
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return Future.value(null);
    return state.pushNamed<T>(routeName, arguments: arguments);
  }

  // Future<T?> _replaceWith<T>(String routeName, {Object? arguments}) =>
  //     Navigator.of(
  //       this,
  //     ).pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);

  Future<T?> clearAndPush<T>(String routeName, {Object? arguments}) {
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return Future.value(null);
    return state.pushNamedAndRemoveUntil<T>(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }

  // ── Generales ──────────────────────────────────────────────

  void goBack<T>([T? result]) {
    if (Navigator.of(this).canPop()) Navigator.of(this).pop(result);
  }

  bool canGoBack() => Navigator.of(this).canPop();

  // ── Rutas críticas ─────────────────────────────────────────

  Future<void> goToLogin() => clearAndPush(AppRoutes.login);
  Future<void> goToHome() => clearAndPush(AppRoutes.home);

  // ── Módulos principales ────────────────────────────────────

  Future<void> goToSeguimiento() => clearAndPush(AppRoutes.seguimiento);
  Future<void> goToPropuestas() => clearAndPush(AppRoutes.propuestas);
  Future<void> goToChats() => clearAndPush(AppRoutes.chats);
  Future<void> goToCobranza() => clearAndPush(AppRoutes.cobranza);
  Future<void> goToSettings() => clearAndPush(AppRoutes.settings);
  Future<void> goToChangePassword() => clearAndPush(AppRoutes.changePassword);

  Future<List<AssetEntity>?> goToMediaPicker() =>
      _push<List<AssetEntity>>(AppRoutes.mediaPicker);

  // ── Home ───────────────────────────────────────────────────

  Future<void> goToNotifications() => _push(AppRoutes.notifications);

  // ── Chats ──────────────────────────────────────────────────

  Future<void> goToDetalleChat({required int idLead}) =>
      _push(AppRoutes.detalleChat, arguments: {'idLead': idLead});

  Future<void> goToEditarLead({
    required InfoLead lead,
    required InfoLeadCubit cubit,
  }) => _push(
    AppRoutes.detalleEditarLead,
    arguments: {'lead': lead, 'cubit': cubit},
  );

  /// Retorna el [Template] seleccionado, o null si el usuario canceló.
  Future<Template?> goToTemplates({required InfoLead lead}) =>
      _push<Template>(AppRoutes.templates, arguments: {'lead': lead});

  /// Navega a un chat desde home: limpia el stack, pone ChatList como base
  /// y apila ChatDetail encima para que el back funcione correctamente.
  Future<void> goToDetalleChatDesdeHome({required int idLead}) {
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return Future.value();
    state.pushNamedAndRemoveUntil(AppRoutes.chats, (_) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'idLead': idLead});
    return Future.value();
  }

  // ── Diálogos ───────────────────────────────────────────────

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(AppImages.logoGs1Peru, height: 36),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: colorScheme.outlineVariant,
                  height: 24,
                  indent: 24,
                  endIndent: 24,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(confirmText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> logoutWithConfirmation(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      title: 'Cerrar Sesión',
      message: '¿Estás seguro que deseas salir?',
      confirmText: 'Salir',
      cancelText: 'Cancelar',
    );
    if (confirmed && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}

// ── NavigationService (sin context) ───────────────────────────

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);

  static void goBack<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop(result);
    }
  }
}
