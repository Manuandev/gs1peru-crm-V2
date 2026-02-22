// lib/config/router/app_router.dart

import 'package:app_crm/features/auth/presentation/pages/login_page.dart';
import 'package:app_crm/features/auth/presentation/pages/splash_page.dart';
import 'package:app_crm/core/constants/app_colors.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
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

  /// Generador principal de rutas
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;

    if (routeName == null) {
      return _buildErrorRoute();
    }

    final WidgetBuilder? builder = _findRouteBuilder(routeName);

    if (builder == null) {
      return _buildErrorRoute();
    }

    return _buildRoute(
      builder: builder,
      settings: settings,
      routeName: routeName,
    );
  }

  /// Buscar el builder de la ruta
  static WidgetBuilder? _findRouteBuilder(String routeName) {
    // Rutas de autenticación
    if (_authRoutes.containsKey(routeName)) {
      return _authRoutes[routeName];
    }

    // Rutas principales
    if (_mainRoutes.containsKey(routeName)) {
      return _mainRoutes[routeName];
    }

    // Rutas de leads
    if (routeName.startsWith('/leads/')) {
      return _leadsRoutes[routeName];
    }

    // // Rutas de recordatorios
    // if (routeName.startsWith('/recordatorios/')) {
    //   return _recordatoriosRoutes[routeName];
    // }

    // // Rutas de chats
    // if (routeName.startsWith('/chats/')) {
    //   return _chatsRoutes[routeName];
    // }

    // // Rutas de cobranzas
    // if (routeName.startsWith('/cobranza/')) {
    //   return _cobranzaRoutes[routeName];
    // }

    return null;
  }

  // ============================================================
  // RUTAS DE AUTENTICACIÓN
  // ============================================================

  static final Map<String, WidgetBuilder> _authRoutes = {
    AppRoutes.splash: (_) => const SplashPage(),

    AppRoutes.login: (_) => const LoginPage(),

    AppRoutes.changePassword: (_) =>
        const Scaffold(body: Center(child: Text('Cambiar Contraseña'))),
  };

  // ============================================================
  // RUTAS PRINCIPALES
  // ============================================================

  static final Map<String, WidgetBuilder> _mainRoutes = {
    AppRoutes.home: (_) => const HomePage(),
  };

  // ============================================================
  // RUTAS DE LEADS
  // ============================================================

  static final Map<String, WidgetBuilder> _leadsRoutes = {
    AppRoutes.leadInfo: (context) {
      final args = _getArgs<Map<String, dynamic>>(context);
      final idLead = args['idLead'];

      return Scaffold(body: Center(child: Text('Id Lead: $idLead')));
    },
    AppRoutes.leadInfos: (context) {
      final args = _getArgs<Map<String, dynamic>>(context);
      final idLead = args['idLead'];

      return Scaffold(
        body: Center(child: Text('Id Leadsssssssssssssss: $idLead')),
      );
    },
  };

  // ============================================================
  // HELPERS
  // ============================================================

  /// Obtener argumentos de forma segura
  static T _getArgs<T>(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      throw Exception(
        'Argumentos esperados pero no recibidos en ${ModalRoute.of(context)?.settings.name}',
      );
    }
    return args as T;
  }

  /// Construir ruta con transición
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

  /// Determinar tipo de transición según ruta
  static TransitionType _getTransitionType(String routeName) {
    // Splash y Login: Fade
    if (routeName == AppRoutes.splash || routeName == AppRoutes.login) {
      return TransitionType.fade;
    }

    // Rutas de escaneo/QR: Slide desde abajo
    if (routeName.contains('/escanear') || routeName.contains('/qr')) {
      return TransitionType.slideUp;
    }

    // Rutas de información: Slide desde derecha
    if (routeName.contains('/informacion')) {
      return TransitionType.slideRight;
    }

    return TransitionType.material;
  }

  /// Construir animación de transición
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
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );

      default:
        return child;
    }
  }

  /// Página de error 404
  static Route<dynamic> _buildErrorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text('404', style: AppTextStyles.displayMedium),
              SizedBox(height: 8),
              Text('Página no encontrada'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tipos de transición
enum TransitionType { material, fade, slideRight, slideUp }
