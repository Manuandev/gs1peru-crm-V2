// lib/config/router/app_router.dart

import 'package:app_crm/config/router/navigation_extensions.dart';
import 'package:app_crm/core/constants/app_icons.dart';
import 'package:app_crm/features/auth/presentation/pages/login_page.dart';
import 'package:app_crm/features/auth/presentation/pages/splash_page.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/chat/presentation/pages/chats_page.dart';
import 'package:app_crm/features/recordatorio/presentation/pages/recordatorios_page.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/features/home/presentation/pages/home_page.dart';

import 'app_routes.dart';

// Importa tus páginas aquí

/// Sistema de routing principal
/// - Organizado por módulos
/// - Type-safe con AppRoutes
/// - Control de stack para evitar acumulación de memoria
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    if (routeName == null) return _buildErrorRoute();

    final WidgetBuilder? builder = _findRouteBuilder(routeName);
    if (builder == null) return _buildErrorRoute();

    return _buildRoute(builder: builder, settings: settings, routeName: routeName);
  }

  static WidgetBuilder? _findRouteBuilder(String routeName) {
    if (_authRoutes.containsKey(routeName)) return _authRoutes[routeName];
    if (_mainRoutes.containsKey(routeName)) return _mainRoutes[routeName];
    if (routeName.startsWith('/leads/')) return _leadsRoutes[routeName];
    if (routeName.startsWith('/recordatorios/')) return _recordatoriosRoutes[routeName];
    if (routeName.startsWith('/chats/')) return _chatsRoutes[routeName];
    return null;
  }

  // ── AUTH ──────────────────────────────────────────────────────
  static final Map<String, WidgetBuilder> _authRoutes = {
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.changePassword: (_) =>
        const Scaffold(body: Center(child: Text('Cambiar Contraseña'))),
  };

  // ── PRINCIPALES ───────────────────────────────────────────────
  static final Map<String, WidgetBuilder> _mainRoutes = {
    AppRoutes.home: (_) => const HomePage(),
    AppRoutes.recordatorios: (_) => const RecordatoriosPage(),
    AppRoutes.chats: (_) => const ChatsPage(),
  };

  // ── LEADS ─────────────────────────────────────────────────────
  static final Map<String, WidgetBuilder> _leadsRoutes = {
    AppRoutes.leadInfo: (context) {
      final args = _getArgs<Map<String, dynamic>>(context);
      final idLead = args['id_lead'];
      return Scaffold(body: Center(child: Text('Lead: $idLead')));
    },
  };

  // ── RECORDATORIOS ─────────────────────────────────────────────
  static final Map<String, WidgetBuilder> _recordatoriosRoutes = {};

  // ── CHATS ─────────────────────────────────────────────────────
  static final Map<String, WidgetBuilder> _chatsRoutes = {
    AppRoutes.detalleChat: (context) {
      final args = _getArgs<Map<String, dynamic>>(context);
      final chat = args['chat'];
      // return DetalleChatPage(chat: chat);
      return Scaffold(body: Center(child: Text('Lead: $chat')));
    },
  };

  // ── HELPERS ───────────────────────────────────────────────────
  static T _getArgs<T>(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      throw Exception(
        'Argumentos faltantes en ${ModalRoute.of(context)?.settings.name}',
      );
    }
    return args as T;
  }

  static Route<dynamic> _buildRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
    required String routeName,
  }) {
    final transitionType = _getTransitionType(routeName);

    if (transitionType == TransitionType.material) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(transitionType, animation, child);
      },
    );
  }

  static TransitionType _getTransitionType(String routeName) {
    if (routeName == AppRoutes.splash || routeName == AppRoutes.login) {
      return TransitionType.fade;
    }
    // Detalle de chat: entra desde la derecha
    if (routeName.contains('/detalle') || routeName.contains('/informacion')) {
      return TransitionType.slideRight;
    }
    return TransitionType.material;
  }

  static Widget _buildTransition(
    TransitionType type,
    Animation<double> animation,
    Widget child,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      default:
        return child;
    }
  }

  static Route<dynamic> _buildErrorRoute() {
    return MaterialPageRoute(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            NavigationService.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.error, size: 64, color: AppColors.error),
                SizedBox(height: 16),
                Text('404', style: AppTextStyles.displayMedium),
                SizedBox(height: 8),
                Text('Página no encontrada'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum TransitionType { material, fade, slideRight, slideUp }