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
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

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
    AppRoutes.recuperarClave: RouteDefinition(
      builder: (_) => const RecuperarClavePage(),
      transition: TransitionType.slideRight,
    ),

    // PRINCIPALES
    AppRoutes.home: RouteDefinition(builder: (_) => const HomePage()),
    AppRoutes.chats: RouteDefinition(builder: (_) => const ChatListPage()),
    AppRoutes.settings: RouteDefinition(builder: (_) => const SettingsPage()),

    AppRoutes.seguimiento: RouteDefinition(
      builder: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return LeadListPage(
          filtroInicial: args?['filtroInicial'] as LeadListFiltro?,
        );
      },
    ),
    AppRoutes.contactos: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (_) => const UnderConstructionPage(routeName: 'Contactos'),
    ),
    AppRoutes.solicitudes: RouteDefinition(
      builder: (_) => const SolicitudListPage(),
    ),
    AppRoutes.detalleSolicitud: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SolicitudDetallePage(
          solicitud: args['solicitud'] as Solicitud,
          origenValidar: args['origenValidar'] as bool? ?? false,
        );
      },
    ),
    AppRoutes.fichaCompletarSolicitud: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SolicitudCompletarPage(
          solicitud: args['solicitud'] as Solicitud,
          modoEdicion: args['modoEdicion'] as bool,
          cantidadNegociacion: args['cantidadNegociacion'] as int?,
          precioBaseNegociacion: args['precioBaseNegociacion'] as double?,
          descuentoNegociacion: args['descuentoNegociacion'] as double?,
          idMonedaNegociacion: args['idMonedaNegociacion'] as String?,
          precioTotalNegociacion: args['precioTotalNegociacion'] as double?,
          nombresNegociacion: args['nombresNegociacion'] as String?,
          apellidoPaternoNegociacion:
              args['apellidoPaternoNegociacion'] as String?,
          apellidoMaternoNegociacion:
              args['apellidoMaternoNegociacion'] as String?,
          nombreEmpresaNegociacion: args['nombreEmpresaNegociacion'] as String?,
          correoNegociacion: args['correoNegociacion'] as String?,
          celularNegociacion: args['celularNegociacion'] as String?,
          celularCodigoTelefonoNegociacion:
              args['celularCodigoTelefonoNegociacion'] as String?,
          rucNegociacion: args['rucNegociacion'] as String?,
          cargoNegociacion: args['cargoNegociacion'] as String?,
        );
      },
    ),
    AppRoutes.solicitudGenerada: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SolicitudGeneradaPage(
          solicitud: args['solicitud'] as Solicitud,
          comprobante: args['comprobante'] as String? ?? '',
        );
      },
    ),
    AppRoutes.cargaMasivaParticipantes: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SolicitudCargaMasivaPage(
          cubit: args['cubit'] as ParticipantesCubit,
          cantidadEsperada: args['cantidadEsperada'] as int?,
        );
      },
    ),
    AppRoutes.misCasos: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (_) => const UnderConstructionPage(routeName: 'Mis casos'),
    ),
    AppRoutes.equipo: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (_) => const UnderConstructionPage(routeName: 'Equipo'),
    ),
    AppRoutes.cobranza: RouteDefinition(
      builder: (_) => const CobranzaListPage(),
    ),
    AppRoutes.detalleCobranza: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaDetallePage(idCobranza: args['numSol'] as String);
      },
    ),
    AppRoutes.facturarCobranza: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaFacturaPage(
          idCobranza: args['idCobranza'] as String,
          nombre: args['nombre'] as String,
          oportunidad: args['oportunidad'] as String,
          montoTotal: args['montoTotal'] as double,
          moneda: args['moneda'] as String,
          idCondicion: args['idCondicion'] as String,
          condicion: args['condicion'] as String,
        );
      },
    ),

    AppRoutes.planCredito: RouteDefinition<PlanCreditoResultado>(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return CobranzaPlanPage(
          idCobranza: args['idCobranza'] as String,
          nombre: args['nombre'] as String,
          oportunidad: args['oportunidad'] as String,
          montoTotal: args['montoTotal'] as double,
          moneda: args['moneda'] as String,
          detraccion: args['detraccion'] as double,
          importeCredito: args['importeCredito'] as double,
          cuotasIniciales:
              args['cuotasIniciales'] as List<CuotaPlan>? ?? const [],
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
    // CONTACTO — detalle de contacto (tabs Info + Negociaciones + Historial)
    AppRoutes.detalleContacto: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return ContactoDetallePage(idContacto: args['idContacto'] as int);
      },
    ),
    // CONTACTO — crear/editar (solo recibe idNumero, carga sus propios datos)
    AppRoutes.editarContacto: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return EditContactoPage(idNumero: args['idNumero'] as int);
      },
    ),
    // CONTACTO — versión reducida (pedido de negocio 2026-07-27, ver
    // lead/CLAUDE.md) — no reemplaza a la de arriba, que sigue intacta.
    AppRoutes.editarContactoSimple: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return EditContactoSimplePage(idNumero: args['idNumero'] as int);
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
        return ChatDetailPage(
          idChatCab: int.tryParse(args['idChatCab'].toString()) ?? 0,
        );
      },
    ),
    AppRoutes.detalleEditarLead: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        final idLead = args['idLead'] as int? ?? 0;
        final existingCubit = args['cubit'] as InfoLeadCubit?;
        final soloLectura = args['soloLectura'] as bool? ?? false;
        final desdeConversacion = args['desdeConversacion'] as bool? ?? false;

        // Siempre se necesita un InfoLeadCubit en el árbol para EditLeadView.
        Widget infoLeadProvider(Widget child) {
          if (existingCubit != null) {
            return BlocProvider.value(value: existingCubit, child: child);
          }
          return BlocProvider<InfoLeadCubit>(
            create: (ctx) => InfoLeadCubit(
              GetInfoUseCase(ctx.read<ChatRepository>()),
              UpdateLeadEstadoUseCase(ctx.read<ChatRepository>()),
              UpdateLeadInfoUseCase(ctx.read<LeadRepository>()),
              GetLeadDetalleUseCase(ctx.read<LeadRepository>()),
            )..cargarPorIdLead(idLead),
            child: child,
          );
        }

        return infoLeadProvider(
          EditLeadPage(
            idLead: idLead,
            soloLectura: soloLectura,
            desdeConversacion: desdeConversacion,
          ),
        );
      },
    ),
    AppRoutes.templates: RouteDefinition<Plantilla>(
      // T = Template: Navigator.pop<Template>(context, template) funciona
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return SelectTemplatePage(negociacion: args['lead'] as Negociacion);
      },
    ),
    AppRoutes.templateForm: RouteDefinition(
      transition: TransitionType.slideRight,
      builder: (context) {
        final args = _requireArgs<Map<String, dynamic>>(context);
        return TemplateFormPage(idPlantilla: args['idPlantilla'] as int?);
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
