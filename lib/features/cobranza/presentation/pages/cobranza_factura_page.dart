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
  final String idCondicion;
  final String condicion;

  const CobranzaFacturaPage({
    super.key,
    required this.idCobranza,
    required this.nombre,
    required this.oportunidad,
    required this.montoTotal,
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
        idCondicion: idCondicion,
        condicion: condicion,
        guardarBorradorUseCase: GuardarBorradorUseCase(repo),
        facturarContadoUseCase: FacturarContadoUseCase(repo),
      ),
      child: BlocListener<CobranzaFacturaBloc, CobranzaFacturaState>(
        listenWhen: (prev, curr) =>
            curr.status != prev.status &&
            curr.status != CobranzaFacturaStatus.idle &&
            curr.status != CobranzaFacturaStatus.loading,
        listener: (context, state) {
          switch (state.status) {
            case CobranzaFacturaStatus.borradorGuardado:
              AppSnackBar.success(context, 'Borrador guardado correctamente');
              context.goToCobranza();
            case CobranzaFacturaStatus.facturadoOk:
              AppSnackBar.success(context, 'Factura generada correctamente');
              context.goToCobranza();
            case CobranzaFacturaStatus.continuarPlan:
              context.goToPlanCredito(
                idCobranza: state.idCobranza,
                nombre: state.nombre,
                oportunidad: state.oportunidad,
                montoTotal: state.montoTotal,
                detraccion: state.detraccion,
                importeCredito: state.importeCredito,
              );
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
