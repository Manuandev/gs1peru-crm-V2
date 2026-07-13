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
        facturarContadoUseCase: FacturarContadoUseCase(repo),
      ),
      child: BlocListener<CobranzaFacturaBloc, CobranzaFacturaState>(
        listenWhen: (prev, curr) =>
            curr.status != prev.status &&
            curr.status != CobranzaFacturaStatus.idle &&
            curr.status != CobranzaFacturaStatus.loading,
        listener: (context, state) async {
          switch (state.status) {
            case CobranzaFacturaStatus.facturadoOk:
              AppSnackBar.success(context, 'Factura generada correctamente');
              context.goToCobranza();
            case CobranzaFacturaStatus.continuarPlan:
              // Espera el resultado: null si el usuario volvió sin guardar
              // el plan, o la fecha de vencimiento más alta si lo guardó.
              final fechaGuardada = await context.goToPlanCredito(
                idCobranza: state.idCobranza,
                nombre: state.nombre,
                oportunidad: state.oportunidad,
                montoTotal: state.montoTotal,
                moneda: state.moneda,
                detraccion: state.detraccion,
                importeCredito: state.importeCredito,
              );
              if (fechaGuardada != null && fechaGuardada.isNotEmpty && context.mounted) {
                context.read<CobranzaFacturaBloc>().add(PlanGuardado(fechaGuardada));
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
