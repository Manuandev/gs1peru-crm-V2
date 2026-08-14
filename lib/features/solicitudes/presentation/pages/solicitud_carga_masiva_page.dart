// lib/features/solicitudes/presentation/pages/solicitud_carga_masiva_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCargaMasivaPage extends StatelessWidget {
  final ParticipantesCubit cubit;
  final int? cantidadEsperada;
  final double precioTotalLead;

  const SolicitudCargaMasivaPage({
    super.key,
    required this.cubit,
    this.cantidadEsperada,
    this.precioTotalLead = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: SolicitudCargaMasivaView(
        cantidadEsperada: cantidadEsperada,
        precioTotalLead: precioTotalLead,
      ),
    );
  }
}
