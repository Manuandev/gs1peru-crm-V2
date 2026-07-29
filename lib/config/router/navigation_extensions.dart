// lib/config/router/navigation_extensions.dart

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

import '../../features/cobranza/index_cobranza.dart';

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

  Future<void> goToSeguimiento({LeadListFiltro? filtroInicial}) => clearAndPush(
    AppRoutes.seguimiento,
    arguments: filtroInicial != null ? {'filtroInicial': filtroInicial} : null,
  );
  Future<void> goToContactos() => clearAndPush(AppRoutes.contactos);
  Future<void> goToSolicitudes() => clearAndPush(AppRoutes.solicitudes);
  Future<void> goToMisCasos() => clearAndPush(AppRoutes.misCasos);
  Future<void> goToEquipo() => clearAndPush(AppRoutes.equipo);
  Future<void> goToChats() => clearAndPush(AppRoutes.chats);
  Future<void> goToCobranza() => clearAndPush(AppRoutes.cobranza);
  // origenValidar: true cuando se navega desde el botón "Validar" de la
  // card (SolicitudAccionTipo.sinValidar) — el detalle muestra "Validar" en
  // vez de "Editar ficha" en ese caso (mismo mecanismo, otro texto). Ver
  // solicitudes/CLAUDE.md.
  Future<void> goToDetalleSolicitud({
    required Solicitud solicitud,
    bool origenValidar = false,
  }) => _push(
    AppRoutes.detalleSolicitud,
    arguments: {'solicitud': solicitud, 'origenValidar': origenValidar},
  );

  Future<void> goToFichaCompletarSolicitud({
    required Solicitud solicitud,
    required bool modoEdicion,
    // Datos de la negociación de origen — solo al crear una solicitud
    // nueva ("Generar solicitud"). Ver SolicitudFormCubit.sembrarDatosNegociacion.
    int? cantidadNegociacion,
    double? precioBaseNegociacion,
    double? descuentoNegociacion,
    String? idMonedaNegociacion,
    // Datos "de referencia" de la negociación — solo prellenan el paso 1,
    // no bloquean nada (a diferencia de los 4 de arriba).
    double? precioTotalNegociacion,
    String? nombresNegociacion,
    String? apellidoPaternoNegociacion,
    String? apellidoMaternoNegociacion,
    String? nombreEmpresaNegociacion,
    String? correoNegociacion,
    String? celularNegociacion,
    String? celularCodigoTelefonoNegociacion,
    String? rucNegociacion,
    String? cargoNegociacion,
  }) => _push(
    AppRoutes.fichaCompletarSolicitud,
    arguments: {
      'solicitud': solicitud,
      'modoEdicion': modoEdicion,
      'cantidadNegociacion': cantidadNegociacion,
      'precioBaseNegociacion': precioBaseNegociacion,
      'descuentoNegociacion': descuentoNegociacion,
      'idMonedaNegociacion': idMonedaNegociacion,
      'precioTotalNegociacion': precioTotalNegociacion,
      'nombresNegociacion': nombresNegociacion,
      'apellidoPaternoNegociacion': apellidoPaternoNegociacion,
      'apellidoMaternoNegociacion': apellidoMaternoNegociacion,
      'nombreEmpresaNegociacion': nombreEmpresaNegociacion,
      'correoNegociacion': correoNegociacion,
      'celularNegociacion': celularNegociacion,
      'celularCodigoTelefonoNegociacion': celularCodigoTelefonoNegociacion,
      'rucNegociacion': rucNegociacion,
      'cargoNegociacion': cargoNegociacion,
    },
  );

  Future<void> goToSolicitudGenerada({
    required Solicitud solicitud,
    String comprobante = '',
  }) => _push(
    AppRoutes.solicitudGenerada,
    arguments: {'solicitud': solicitud, 'comprobante': comprobante},
  );

  Future<void> goToCargaMasivaParticipantes({
    required ParticipantesCubit cubit,
  }) => _push(AppRoutes.cargaMasivaParticipantes, arguments: {'cubit': cubit});

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
  }) => _push(
    AppRoutes.facturarCobranza,
    arguments: {
      'idCobranza': idCobranza,
      'nombre': nombre,
      'oportunidad': oportunidad,
      'montoTotal': montoTotal,
      'moneda': moneda,
      'idCondicion': idCondicion,
      'condicion': condicion,
    },
  );

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
  }) => _push<PlanCreditoResultado>(
    AppRoutes.planCredito,
    arguments: {
      'idCobranza': idCobranza,
      'nombre': nombre,
      'oportunidad': oportunidad,
      'montoTotal': montoTotal,
      'moneda': moneda,
      'detraccion': detraccion,
      'importeCredito': importeCredito,
      'cuotasIniciales': cuotasIniciales,
    },
  );
  Future<void> goToSettings() => clearAndPush(AppRoutes.settings);
  Future<void> goToChangePassword() => clearAndPush(AppRoutes.changePassword);

  Future<List<AssetEntity>?> goToMediaPicker() =>
      _push<List<AssetEntity>>(AppRoutes.mediaPicker);

  // ── Lead — detalle contacto ────────────────────────────────

  Future<void> goToDetalleContacto({required int idNumero}) =>
      _push(AppRoutes.detalleContacto, arguments: {'idNumero': idNumero});

  Future<void> goToEditarContacto({required int idNumero}) =>
      _push(AppRoutes.editarContacto, arguments: {'idNumero': idNumero});

  // Pantalla reducida — pedido de negocio 2026-07-27, ver lead/CLAUDE.md.
  Future<void> goToEditarContactoSimple({required int idNumero}) => _push(
    AppRoutes.editarContactoSimple,
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
    bool desdeConversacion = false,
  }) => _push(
    AppRoutes.detalleEditarLead,
    arguments: {
      'idLead': idLead,
      'cubit': cubit,
      'soloLectura': soloLectura,
      'desdeConversacion': desdeConversacion,
    },
  );

  /// Retorna el [Template] seleccionado, o null si el usuario canceló.
  Future<Plantilla?> goToTemplates({required Negociacion negociacion}) =>
      _push<Plantilla>(AppRoutes.templates, arguments: {'lead': negociacion});

  /// Crear (`idPlantilla` null) o editar (`idPlantilla` con valor) una plantilla.
  Future<void> goToTemplateForm({int? idPlantilla}) => _push(
    AppRoutes.templateForm,
    arguments: {'idPlantilla': idPlantilla},
  );

  /// Navega a un chat desde home: limpia el stack, pone ChatList como base
  /// y apila ChatDetail encima para que el back funcione correctamente.
  Future<void> goToDetalleChatDesdeHome({required int idChatCab}) {
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return Future.value();
    state.pushNamedAndRemoveUntil(AppRoutes.chats, (_) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'idChatCab': idChatCab});
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
