// lib/features/cobranza/presentation/pages/cobranza_factura_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaFacturaPage extends StatelessWidget {
  final int idCobranza;
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
    return BlocProvider(
      create: (_) => CobranzaFacturaBloc(
        idCobranza: idCobranza,
        nombre: nombre,
        oportunidad: oportunidad,
        montoTotal: montoTotal,
        idCondicion: idCondicion,
        condicion: condicion,
      ),
      child: const CobranzaFacturaView(),
    );
  }
}
