// lib/config/router/navigation_extensions.dart

import 'package:app_crm/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_crm/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension NavigationExtensions on BuildContext {
  // ============================================================
  // NAVEGACIÓN BÁSICA
  // ============================================================

  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  void goBack<T>([T? result]) {
    if (Navigator.of(this).canPop()) Navigator.of(this).pop(result);
  }

  bool canGoBack() => Navigator.of(this).canPop();

  Future<T?> replaceWith<T>(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);
  }

  Future<T?> clearStackAndNavigateTo<T>(String routeName, {Object? arguments}) {
    return NavigationService.navigatorKey.currentState!
        .pushNamedAndRemoveUntil<T>(
          routeName,
          (route) => false,
          arguments: arguments,
        );
  }

  // ============================================================
  // RUTAS CRÍTICAS
  // ============================================================

  Future<void> goToLogin() => clearStackAndNavigateTo(AppRoutes.login);
  Future<void> goToHome() => clearStackAndNavigateTo(AppRoutes.home);
  Future<void> logout() => clearStackAndNavigateTo(AppRoutes.login);

  // ============================================================
  // MÓDULOS PRINCIPALES
  // ============================================================

  Future<void> goToLeads() => clearStackAndNavigateTo(AppRoutes.leads);
  Future<void> goToRecordatorios() =>
      clearStackAndNavigateTo(AppRoutes.recordatorios);
  Future<void> goToChats() => clearStackAndNavigateTo(AppRoutes.chats);
  Future<void> goToCobranza() => clearStackAndNavigateTo(AppRoutes.cobranza);
  Future<void> goToChangePassword() =>
      clearStackAndNavigateTo(AppRoutes.changePassword);

  // ============================================================
  // MÓDULOS SECUNDARIOS
  // ============================================================

  Future<void> goToLeadInfo({required dynamic idLead}) {
    return navigateTo(AppRoutes.leadInfo, arguments: {'id_lead': idLead});
  }

  // ============================================================
  // DIÁLOGOS
  // ============================================================

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
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

  // ============================================================
  // SNACKBARS — todos usan AppColors, cero Colors.x sueltos
  // ============================================================

  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.error, color: AppColors.onError),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.checkCircle, color: AppColors.onSuccess),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showWarningSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.warning, color: AppColors.onWarning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: AppTextStyles.snackWarningText),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showInfoSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.infoCircle, color: AppColors.onInfo),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ============================================================
// NAVEGACIÓN SIN CONTEXT
// ============================================================

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static void goBack<T>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }
}
