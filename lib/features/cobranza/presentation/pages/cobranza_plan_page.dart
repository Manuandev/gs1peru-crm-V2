// lib/features/cobranza/presentation/pages/cobranza_plan_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaPlanPage extends StatelessWidget {
  final String idCobranza;
  final String nombre;
  final String oportunidad;
  final double montoTotal;
  final String moneda;
  final double detraccion;
  final double importeCredito;

  const CobranzaPlanPage({
    super.key,
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
    required this.moneda,
    required this.detraccion,
    required this.importeCredito,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CobranzaRepository>();
    return BlocProvider(
      create: (_) => CobranzaPlanBloc(
        idCobranza: idCobranza,
        nombre: nombre,
        oportunidad: oportunidad,
        montoTotal: montoTotal,
        moneda: moneda,
        detraccion: detraccion,
        importeCredito: importeCredito,
        guardarPlanCreditoUseCase: GuardarPlanCreditoUseCase(repo),
      )..add(const CobranzaPlanStarted()),
      child: BlocListener<CobranzaPlanBloc, CobranzaPlanState>(
        listenWhen: (prev, curr) =>
            curr.status != prev.status &&
            curr.status != CobranzaPlanStatus.idle &&
            curr.status != CobranzaPlanStatus.loading,
        listener: (context, state) {
          switch (state.status) {
            case CobranzaPlanStatus.guardado:
              // Guardar el plan es un paso extra antes de facturar, no el
              // final del flujo — vuelve a CobranzaFacturaPage (no a la
              // lista) devolviendo la fecha de vencimiento más alta.
              context.goBack(state.fechaMasAlta);
            case CobranzaPlanStatus.error:
              AppSnackBar.error(
                context,
                state.mensajeError ?? 'Error al guardar el plan',
              );
            default:
              break;
          }
        },
        child: const CobranzaPlanView(),
      ),
    );
  }
}
