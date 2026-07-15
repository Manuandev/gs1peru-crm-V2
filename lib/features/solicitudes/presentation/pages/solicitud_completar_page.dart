// lib/features/solicitudes/presentation/pages/solicitud_completar_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCompletarPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Datos de la negociación de origen — solo llegan al crear una solicitud
  // nueva desde "Generar solicitud" (nunca al editar una ya existente, ver
  // SolicitudFormState.cantidadEsperada).
  final int? cantidadNegociacion;
  final double? precioBaseNegociacion;
  final double? descuentoNegociacion;
  final String? idMonedaNegociacion;

  const SolicitudCompletarPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    this.cantidadNegociacion,
    this.precioBaseNegociacion,
    this.descuentoNegociacion,
    this.idMonedaNegociacion,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = SolicitudFormCubit();
            final cantidad = cantidadNegociacion;
            // Solo tiene sentido sembrar en creación (numSol vacío) — al
            // editar una solicitud ya existente estos argumentos nunca
            // llegan (los call sites no los mandan en ese caso).
            if (solicitud.idSolicitud.isEmpty && cantidad != null) {
              cubit.sembrarDatosNegociacion(
                cantidad: cantidad,
                precioBase: precioBaseNegociacion ?? 0,
                descuento: descuentoNegociacion ?? 0,
                idMoneda: idMonedaNegociacion ?? '',
              );
            }
            return cubit;
          },
        ),
        BlocProvider(create: (_) => ParticipantesCubit()),
      ],
      child: SolicitudWizardView(
        solicitud: solicitud,
        modoEdicion: modoEdicion,
      ),
    );
  }
}
