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

  const CobranzaFacturaPage({
    super.key,
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.moneda,
    required this.idCondicion,
    required this.condicion,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CobranzaRepository>();
    return BlocProvider(
      create: (_) => CobranzaFacturaBloc(
        idCobranza: idCobranza,
        nombre: nombre,
        oportunidad: oportunidad,
        montoTotal: montoTotal,
        moneda: moneda,
        idCondicion: idCondicion,
        condicion: condicion,
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
              // Espera el resultado: null si el usuario volvió sin guardar
              // el plan, o fecha+cuotas si lo guardó localmente (el RC real
              // recién se manda al presionar "Facturar", ver el bloc).
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
