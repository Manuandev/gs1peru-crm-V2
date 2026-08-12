// lib/features/lead/domain/entities/datos_prellenado_solicitud.dart

import 'package:app_crm/index_dependencies.dart';

// Datos mínimos para sembrar el paso 1 del wizard de "Generar solicitud"
// (solicitudes/) al crear una solicitud nueva desde una negociación —
// task 'NEG' de CRM.CSV_LEADS_LST_APP, ver lead/CLAUDE.md. A diferencia de
// Negociacion (task 'DT'/'DN'), esta entidad NO trae estado/canal/campaña/
// oportunidad/chat — solo lo que solicitudes/ necesita para
// SolicitudFormCubit.sembrarDatosNegociacion.
class DatosPrellenadoSolicitud extends Equatable {
  final int idLead;
  final int cantidad;
  final double precioBase;
  final double descuento;
  final double precio;
  final String idMoneda;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String correo;
  final String celular;
  final String celularCodigoTelefono;
  final String ruc;
  final String cargo;
  final String tipoDocId;
  final String numDoc;

  const DatosPrellenadoSolicitud({
    required this.idLead,
    required this.cantidad,
    required this.precioBase,
    required this.descuento,
    required this.precio,
    required this.idMoneda,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombreEmpresa,
    required this.correo,
    required this.celular,
    required this.celularCodigoTelefono,
    required this.ruc,
    required this.cargo,
    required this.tipoDocId,
    required this.numDoc,
  });

  @override
  List<Object?> get props => [
    idLead,
    cantidad,
    precioBase,
    descuento,
    precio,
    idMoneda,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    nombreEmpresa,
    correo,
    celular,
    celularCodigoTelefono,
    ruc,
    cargo,
    tipoDocId,
    numDoc,
  ];
}
