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
  // Datos "de referencia" de la negociación de origen — solo prellenan el
  // paso 1, no bloquean nada (a diferencia de los 4 de arriba). Ver
  // SolicitudFormCubit.sembrarDatosNegociacion.
  final double? precioTotalNegociacion;
  final String? nombresNegociacion;
  final String? apellidoPaternoNegociacion;
  final String? apellidoMaternoNegociacion;
  final String? nombreEmpresaNegociacion;
  final String? correoNegociacion;
  final String? celularNegociacion;
  final String? celularCodigoTelefonoNegociacion;
  final String? rucNegociacion;
  final String? cargoNegociacion;
  // Tipo/N° de documento del contacto — 2026-08-04, mismo candado que el
  // resto ("de referencia", solo prellena). Ver SolicitudFormCubit.
  // sembrarDatosNegociacion.
  final String? tipoDocIdNegociacion;
  final String? numDocNegociacion;

  const SolicitudCompletarPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    this.cantidadNegociacion,
    this.precioBaseNegociacion,
    this.descuentoNegociacion,
    this.idMonedaNegociacion,
    this.precioTotalNegociacion,
    this.nombresNegociacion,
    this.apellidoPaternoNegociacion,
    this.apellidoMaternoNegociacion,
    this.nombreEmpresaNegociacion,
    this.correoNegociacion,
    this.celularNegociacion,
    this.celularCodigoTelefonoNegociacion,
    this.rucNegociacion,
    this.cargoNegociacion,
    this.tipoDocIdNegociacion,
    this.numDocNegociacion,
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
                precioTotal: precioTotalNegociacion ?? 0,
                nombres: nombresNegociacion ?? '',
                apellidoPaterno: apellidoPaternoNegociacion ?? '',
                apellidoMaterno: apellidoMaternoNegociacion ?? '',
                nombreEmpresa: nombreEmpresaNegociacion ?? '',
                correo: correoNegociacion ?? '',
                celular: celularNegociacion ?? '',
                celularCodigoTelefono: celularCodigoTelefonoNegociacion ?? '',
                ruc: rucNegociacion ?? '',
                cargo: cargoNegociacion ?? '',
                tipoDocId: tipoDocIdNegociacion ?? '',
                numDoc: numDocNegociacion ?? '',
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
