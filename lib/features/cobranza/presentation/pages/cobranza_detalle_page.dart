// lib/features/cobranza/presentation/pages/cobranza_detalle_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetallePage extends StatelessWidget {
  final int idCobranza;
  const CobranzaDetallePage({super.key, required this.idCobranza});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CobranzaDetalleBloc()..add(CobranzaDetalleStarted(idCobranza)),
      child: BlocListener<CobranzaDetalleBloc, CobranzaDetalleState>(
        listener: (context, state) {
          if (state is CobranzaDetalleError) {
            AppSnackBar.error(context, state.mensaje);
          }
        },
        child: const CobranzaDetalleView(),
      ),
    );
  }
}
