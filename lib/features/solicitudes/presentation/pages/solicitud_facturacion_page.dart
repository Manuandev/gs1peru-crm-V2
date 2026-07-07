// lib/features/solicitudes/presentation/pages/solicitud_facturacion_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudFacturacionPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  final SolicitudFormCubit formCubit;

  const SolicitudFacturacionPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.formCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: formCubit,
      child: SolicitudFacturacionView(
        solicitud: solicitud,
        modoEdicion: modoEdicion,
      ),
    );
  }
}
