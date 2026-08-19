// lib/features/cobranza/presentation/pages/cobranza_factura_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaPage extends StatelessWidget {
  final String idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final String moneda;
  final String idCondicion;
  final String condicion;
  final String tipoComprobante;

  const CobranzaFacturaPage({
    super.key,
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.moneda,
    required this.idCondicion,
    required this.condicion,
    required this.tipoComprobante,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CobranzaRepository>();
    // Monto convertido a soles (con el tipo de cambio "venta" si la moneda es
    // USD) — se resuelve acá, una sola vez al armar el bloc, contra el
    // catálogo ya cargado en memoria (ver cobranza/CLAUDE.md, regla de
    // detracción). El refresh real (para traer el tipo de cambio del día si
    // recién se registró) pasa por CatalogsLoadRequested antes de "Validar
    // plan de crédito", no acá.
    final catalogState = context.read<CatalogsBloc>().state;
    final monedas = catalogState is CatalogsLoaded
        ? catalogState.monedas
        : const <MonedaItem>[];
    final tipoCambioVenta = catalogState is CatalogsLoaded
        ? catalogState.tipoCambio.venta
        : 0.0;
    final montoTotalEnSoles = esMonedaDolares(monedas, moneda)
        ? montoTotal * tipoCambioVenta
        : montoTotal;
    return BlocProvider(
      create: (_) => CobranzaFacturaBloc(
        idCobranza: idCobranza,
        nombre: nombre,
        oportunidad: oportunidad,
        montoTotal: montoTotal,
        moneda: moneda,
        idCondicion: idCondicion,
        condicion: condicion,
        tipoComprobante: tipoComprobante,
        montoTotalEnSoles: montoTotalEnSoles,
        cambiarEstadoFacturarUseCase: CambiarEstadoFacturarUseCase(repo),
        guardarPlanCreditoUseCase: GuardarPlanCreditoUseCase(repo),
      ),
      child: BlocListener<CobranzaFacturaBloc, CobranzaFacturaState>(
        listenWhen: (prev, curr) =>
            curr.status != prev.status &&
            curr.status != CobranzaFacturaStatus.idle &&
            curr.status != CobranzaFacturaStatus.loading,
        listener: (context, state) async {
          switch (state.status) {
            case CobranzaFacturaStatus.facturadoOk:
              // El check verde ya lo muestra el AppProcessOverlay de la vista
              // (state.status == facturadoOk) — mismo timing que
              // EditLeadPortrait/TemplateFormView, sin snackbar redundante.
              await Future.delayed(const Duration(milliseconds: 1500));
              if (context.mounted) context.goBack();
            case CobranzaFacturaStatus.continuarPlan:
              // Pedido del usuario (2026-08-19) — antes de entrar al Plan de
              // crédito, refresca el catálogo (CatalogsBloc puede traer un
              // tipo de cambio registrado HOY que todavía no estaba en el
              // caché de sesión, ver cobranza/CLAUDE.md). Si la moneda es
              // USD y sigue sin haber tipo de cambio ("venta" en 0) después
              // del refresh, bloquea — no se puede convertir el monto a
              // soles para la regla de detracción, así que no se navega al
              // Plan de crédito hasta que alguien lo registre. El asesor
              // puede reintentar en cualquier momento presionando "Validar
              // plan de crédito" de nuevo — cada intento repite el refresh.
              final catalogsBloc = context.read<CatalogsBloc>();
              final catalogsFuture = catalogsBloc.stream.firstWhere(
                (s) => s is CatalogsLoaded || s is CatalogsError,
              );
              catalogsBloc.add(const CatalogsLoadRequested());
              final nuevoCatalogState = await catalogsFuture;
              if (nuevoCatalogState is CatalogsLoaded) {
                final monedaEsUsd = esMonedaDolares(
                  nuevoCatalogState.monedas,
                  state.moneda,
                );
                if (monedaEsUsd && nuevoCatalogState.tipoCambio.venta <= 0) {
                  if (context.mounted) {
                    AppSnackBar.error(
                      context,
                      'No hay tipo de cambio registrado para hoy. Debe '
                      'registrarse antes de continuar con el plan de crédito.',
                    );
                  }
                  break;
                }
              }

              // Espera el resultado: null si el usuario volvió sin guardar
              // el plan, o fecha+cuotas si lo guardó localmente (el RC real
              // recién se manda al presionar "Facturar", ver el bloc).
              if (!context.mounted) break;
              final resultadoPlan = await context.goToPlanCredito(
                idCobranza: state.idCobranza,
                nombre: state.nombre,
                oportunidad: state.oportunidad,
                montoTotal: state.montoTotal,
                moneda: state.moneda,
                detraccion: state.detraccion,
                importeCredito: state.importeCredito,
                // Si ya había un plan guardado localmente antes, se lo
                // pasamos de vuelta para que no arranque desde cero.
                cuotasIniciales: state.cuotasCredito,
              );
              if (resultadoPlan != null && context.mounted) {
                context.read<CobranzaFacturaBloc>().add(
                  PlanGuardado(
                    resultadoPlan.fechaVencimiento,
                    resultadoPlan.cuotas,
                  ),
                );
                AppSnackBar.success(
                  context,
                  'Plan de crédito guardado — continúa con la facturación',
                );
              }
            case CobranzaFacturaStatus.error:
              AppSnackBar.error(
                context,
                state.mensajeError ?? 'Error al procesar',
              );
            default:
              break;
          }
        },
        child: const CobranzaFacturaView(),
      ),
    );
  }
}
