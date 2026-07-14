// lib/config/router/navigation_extensions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/cobranza/domain/entities/plan_credito_resultado.dart';
import 'package:app_crm/features/cobranza/domain/entities/cobranza_plan.dart';

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
  Future<void> goToRecuperarClave() => _push(AppRoutes.recuperarClave);

  // ── Módulos principales ────────────────────────────────────

  Future<void> goToSeguimiento({LeadListFiltro? filtroInicial}) =>
      clearAndPush(
        AppRoutes.seguimiento,
        arguments: filtroInicial != null
            ? {'filtroInicial': filtroInicial}
            : null,
      );
  Future<void> goToContactos() => clearAndPush(AppRoutes.contactos);
  Future<void> goToSolicitudes() => clearAndPush(AppRoutes.solicitudes);
  Future<void> goToMisCasos() => clearAndPush(AppRoutes.misCasos);
  Future<void> goToEquipo() => clearAndPush(AppRoutes.equipo);
  Future<void> goToChats() => clearAndPush(AppRoutes.chats);
  Future<void> goToCobranza() => clearAndPush(AppRoutes.cobranza);
  Future<void> goToDetalleSolicitud({required Solicitud solicitud}) =>
      _push(AppRoutes.detalleSolicitud, arguments: {'solicitud': solicitud});

  Future<void> goToFichaCompletarSolicitud({
    required Solicitud solicitud,
    required bool modoEdicion,
    // Datos de la negociación de origen — solo al crear una solicitud
    // nueva ("Generar solicitud"). Ver SolicitudFormCubit.sembrarDatosNegociacion.
    int? cantidadNegociacion,
    double? precioBaseNegociacion,
    double? descuentoNegociacion,
    String? idMonedaNegociacion,
  }) => _push(
        AppRoutes.fichaCompletarSolicitud,
        arguments: {
          'solicitud': solicitud,
          'modoEdicion': modoEdicion,
          'cantidadNegociacion': cantidadNegociacion,
          'precioBaseNegociacion': precioBaseNegociacion,
          'descuentoNegociacion': descuentoNegociacion,
          'idMonedaNegociacion': idMonedaNegociacion,
        },
      );

  Future<void> goToFichaParticipantesSolicitud({
    required Solicitud solicitud,
    required bool modoEdicion,
    required SolicitudFormCubit formCubit,
    required ParticipantesCubit participantesCubit,
  }) => _push(
        AppRoutes.fichaParticipantesSolicitud,
        arguments: {
          'solicitud': solicitud,
          'modoEdicion': modoEdicion,
          'formCubit': formCubit,
          'participantesCubit': participantesCubit,
        },
      );

  Future<void> goToFichaFacturacionSolicitud({
    required Solicitud solicitud,
    required bool modoEdicion,
    required SolicitudFormCubit formCubit,
    required ParticipantesCubit participantesCubit,
  }) => _push(
        AppRoutes.fichaFacturacionSolicitud,
        arguments: {
          'solicitud': solicitud,
          'modoEdicion': modoEdicion,
          'formCubit': formCubit,
          'participantesCubit': participantesCubit,
        },
      );

  Future<void> goToFichaResumenSolicitud({
    required Solicitud solicitud,
    required bool modoEdicion,
    required SolicitudFormCubit formCubit,
    required ParticipantesCubit participantesCubit,
  }) => _push(
        AppRoutes.fichaResumenSolicitud,
        arguments: {
          'solicitud': solicitud,
          'modoEdicion': modoEdicion,
          'formCubit': formCubit,
          'participantesCubit': participantesCubit,
        },
      );

  Future<void> goToSolicitudGenerada({required Solicitud solicitud}) =>
      _push(
        AppRoutes.solicitudGenerada,
        arguments: {'solicitud': solicitud},
      );

  Future<void> goToCargaMasivaParticipantes({
    required ParticipantesCubit cubit,
  }) => _push(
        AppRoutes.cargaMasivaParticipantes,
        arguments: {'cubit': cubit},
      );

  Future<void> goToDetalleCobranza({required String numSol}) =>
      _push(AppRoutes.detalleCobranza, arguments: {'numSol': numSol});

  Future<void> goToFacturarCobranza({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required String idCondicion,
    required String condicion,
  }) => _push(AppRoutes.facturarCobranza, arguments: {
        'idCobranza': idCobranza,
        'nombre': nombre,
        'oportunidad': oportunidad,
        'montoTotal': montoTotal,
        'moneda': moneda,
        'idCondicion': idCondicion,
        'condicion': condicion,
      });

  // Devuelve fecha de vencimiento más alta + cuotas del plan "guardado"
  // localmente (RC real todavía no se llamó — eso lo dispara Facturar), o
  // null si el usuario volvió sin guardar (solo pop, ver CobranzaPlanView).
  Future<PlanCreditoResultado?> goToPlanCredito({
    required String idCobranza,
    required String nombre,
    required String oportunidad,
    required double montoTotal,
    required String moneda,
    required double detraccion,
    required double importeCredito,
    List<CuotaPlan> cuotasIniciales = const [],
  }) => _push<PlanCreditoResultado>(AppRoutes.planCredito, arguments: {
        'idCobranza': idCobranza,
        'nombre': nombre,
        'oportunidad': oportunidad,
        'montoTotal': montoTotal,
        'moneda': moneda,
        'detraccion': detraccion,
        'importeCredito': importeCredito,
        'cuotasIniciales': cuotasIniciales,
      });
  Future<void> goToSettings() => clearAndPush(AppRoutes.settings);
  Future<void> goToChangePassword() => clearAndPush(AppRoutes.changePassword);

  Future<List<AssetEntity>?> goToMediaPicker() =>
      _push<List<AssetEntity>>(AppRoutes.mediaPicker);

  // ── Lead — detalle contacto ────────────────────────────────

  Future<void> goToDetalleContacto({required int idNumero}) => _push(
    AppRoutes.detalleContacto,
    arguments: {'idNumero': idNumero},
  );

  // ── Lead — detalle ─────────────────────────────────────────

  Future<void> goToDetalleLead({required int idLead}) =>
      _push(AppRoutes.detalleSeguimiento, arguments: {'idLead': idLead});

  // ── Home ───────────────────────────────────────────────────

  Future<void> goToNotifications() => _push(AppRoutes.notifications);

  // ── Chats ──────────────────────────────────────────────────

  Future<void> goToDetalleChat({required int idChatCab}) =>
      _push(AppRoutes.detalleChat, arguments: {'idChatCab': idChatCab});

  Future<void> goToEditarLead({
    required int idLead,
    InfoLeadCubit? cubit,
    bool soloLectura = false,
  }) => _push(
    AppRoutes.detalleEditarLead,
    arguments: {'idLead': idLead, 'cubit': cubit, 'soloLectura': soloLectura},
  );

  /// Retorna el [Template] seleccionado, o null si el usuario canceló.
  Future<Plantilla?> goToTemplates({required Negociacion negociacion}) =>
      _push<Plantilla>(AppRoutes.templates, arguments: {'lead': negociacion});

  /// Navega a un chat desde home: limpia el stack, pone ChatList como base
  /// y apila ChatDetail encima para que el back funcione correctamente.
  Future<void> goToDetalleChatDesdeHome({required int idChatCab}) {
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return Future.value();
    state.pushNamedAndRemoveUntil(AppRoutes.chats, (_) => false);
    state.pushNamed(
      AppRoutes.detalleChat,
      arguments: {'idChatCab': idChatCab},
    );
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
