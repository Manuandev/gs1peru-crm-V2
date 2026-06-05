// lib/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/home/index_home.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/settings/index_settings.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

// ── Tipos de transición ────────────────────────────────────────

enum TransitionType { material, fade, slideRight }

// ── Definición tipada de ruta ──────────────────────────────────

/// Encapsula el builder y la transición de una ruta.
/// El tipo genérico [T] es el valor de retorno que [Navigator.pop] puede devolver.
class RouteDefinition<T> {
  const RouteDefinition({
    required this.builder,
    this.transition = TransitionType.material,
  });

  final WidgetBuilder builder;
  final TransitionType transition;

  Route<T> build(RouteSettings settings) {
    if (transition == TransitionType.material) {
      return MaterialPageRoute<T>(builder: builder, settings: settings);
    }
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) => builder(context),
      transitionsBuilder: (context, animation, _, child) =>
          AppRouter._applyTransition(transition, animation, child),
    );
  }
}

// ── Router principal ───────────────────────────────────────────

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) return _errorRoute();

    final definition = _registry[routeName];

    if (definition == null) {
      assert(
        false,
        '[AppRouter] Ruta no registrada: "$routeName". Agrégala en AppRouter._registry.',
      );
      return _errorRoute();
    }

    return definition.build(settings);
  }

  // ── Registro de rutas ──────────────────────────────────────
  //
  // Cada entrada es un RouteDefinition<T> donde T es el tipo de retorno.
  // Rutas que no retornan valor usan void (o dynamic por defecto).
  // Rutas que retornan valor declaran su tipo explícito.

  static final Map<String, RouteDefinition<dynamic>> _registry = {
    // AUTH
    AppRoutes.splash: RouteDefinition(
      builder: (_) => const SplashPage(),
      transition: TransitionType.fade,
    ),
    AppRoutes.login: RouteDefinition(
      builder: (_) => const LoginPage(),
      transition: TransitionType.fade,
    ),
    AppRoutes.changePassword: RouteDefinition(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Cambiar Contraseña'))),
    ),

    // PRINCIPALES
    AppRoutes.home: RouteDefinition(builder: (_) => const HomePage()),
    AppRoutes.chats: RouteDefinition(builder: (_) => const ChatListPage()),
    AppRoutes.settings: RouteDefinition(builder: (_) => const SettingsPage()),

    AppRoutes.seguimiento: RouteDefinition(
      builder: (_) => const LeadListPage(type: LeadType.seguimientos),
    ),
    AppRoutes.propuestas: RouteDefinition(
      builder: (_) => const LeadListPage(type: LeadType.propuestas),
    ),

    // PENDIENTES — en construcción
    // AppRoutes.prospectos: RouteDefinition(
    //   builder: (_) => const UnderConstructionPage(routeName: 'Prospectos'),
    //   transition: TransitionType.fade,
    // ),

    // AppRoutes.propuestas: RouteDefinition(
    //   builder: (_) => const UnderConstructionPage(routeName: 'Propuestas'),
    //   transition: TransitionType.fade,
    // ),
    AppRoutes.cobranza: RouteDefinition(
      builder: (_) => const CobranzaListPage(),
    ),
    AppRoutes.detalleCobranza: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaDetallePage(idCobranza: args['idCobranza'] as int);
      },
    ),
    AppRoutes.facturarCobranza: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaFacturaPage(
          idCobranza: args['idCobranza'] as int,
          nombre: args['nombre'] as String,
          oportunidad: args['oportunidad'] as String,
          montoTotal: args['montoTotal'] as double,
          idCondicion: args['idCondicion'] as String,
          condicion: args['condicion'] as String,
        );
      },
    ),

    AppRoutes.planCredito: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaPlanPage(
          idCobranza: args['idCobranza'] as int,
          nombre: args['nombre'] as String,
          oportunidad: args['oportunidad'] as String,
          montoTotal: args['montoTotal'] as double,
          detraccion: args['detraccion'] as double,
          importeCredito: args['importeCredito'] as double,
        );
      },
    ),

    AppRoutes.mediaPicker: RouteDefinition<List<AssetEntity>>(
      transition: TransitionType.slideRight,
      builder: (context) {
        _requireArgs<Map<String, dynamic>>(context);
        return WhatsAppMediaPicker(
          onConfirm: (assets) => Navigator.pop(context, assets),
        );
      },
    ),
    // SEGUIMIENTO / PROPUESTAS — detalle de lead
    AppRoutes.detalleSeguimiento: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return LeadDetallePage(idLead: args['idLead'] as int);
      },
    ),
    AppRoutes.detallePropuesta: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return LeadDetallePage(idLead: args['idLead'] as int);
      },
    ),

    // HOME
    AppRoutes.notifications: RouteDefinition(
      builder: (_) => const NotificationsPage(),
      transition: TransitionType.slideRight,
    ),

    // CHATS
    AppRoutes.detalleChat: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return ChatDetailPage(idLead: int.parse(args['idLead'].toString()));
      },
    ),
    AppRoutes.detalleEditarLead: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return BlocProvider.value(
          value: args['cubit'] as InfoLeadCubit,
          child: EditLeadPage(lead: args['lead'] as InfoLead),
        );
      },
    ),
    AppRoutes.templates: RouteDefinition<Template>(
      // T = Template: Navigator.pop<Template>(context, template) funciona
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SelectTemplatePage(lead: args['lead'] as InfoLead);
      },
    ),
  };

  // ── Helpers ────────────────────────────────────────────────

  static T _requireArgs<T>(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;
    assert(
      args != null,
      '[AppRouter] La ruta "${route?.settings.name}" requiere argumentos de tipo $T.',
    );
    return args as T;
  }

  static Widget _applyTransition(
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
      case TransitionType.material:
        return child;
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            NavigationService.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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
