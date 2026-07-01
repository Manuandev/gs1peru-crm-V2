// lib/features/solicitudes/presentation/bloc/form/solicitud_form_state.dart

part of 'solicitud_form_cubit.dart';

class DatosSolicitante {
  final String tipoPersona;
  final String tipoDocLabel;
  final String numDoc;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String cargo;
  final String celular;
  final String correo;
  final String campana;
  final String evento;
  final List<String> canales;
  final String ruc;
  final String razonSocial;
  final bool solicitanteEsParticipante;
  final bool facturarAlSolicitante;

  const DatosSolicitante({
    required this.tipoPersona,
    required this.tipoDocLabel,
    required this.numDoc,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.cargo,
    required this.celular,
    required this.correo,
    required this.campana,
    required this.evento,
    required this.canales,
    required this.ruc,
    required this.razonSocial,
    required this.solicitanteEsParticipante,
    required this.facturarAlSolicitante,
  });

  String get nombreCompleto => [nombres, apellidoPaterno, apellidoMaterno]
      .where((s) => s.isNotEmpty)
      .join(' ');

  String get documento =>
      tipoDocLabel.isNotEmpty ? '$tipoDocLabel $numDoc' : numDoc;

  String get canalesTexto => canales.isEmpty ? '—' : canales.join(', ');
}

class DatosFacturacion {
  final String tipoPersona;
  final String comprobanteId;
  final String comprobante;
  final String paisId;
  final String pais;
  final String monedaId;
  final String moneda;
  final String tipoDocLabel;
  final String numDoc;
  final String nombresRazon;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String celular;
  final String correo;
  final String direccion;
  final String actividadEconomica;
  final String nit;
  final String observaciones;

  const DatosFacturacion({
    required this.tipoPersona,
    required this.comprobanteId,
    required this.comprobante,
    required this.paisId,
    required this.pais,
    required this.monedaId,
    required this.moneda,
    required this.tipoDocLabel,
    required this.numDoc,
    required this.nombresRazon,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.celular,
    required this.correo,
    required this.direccion,
    required this.actividadEconomica,
    required this.nit,
    required this.observaciones,
  });

  String get tipoPersonaLabel =>
      tipoPersona == 'juridica' ? 'Jurídica' : 'Natural';
}

class SolicitudFormState {
  final DatosSolicitante? solicitante;
  final DatosFacturacion? facturacion;

  const SolicitudFormState({this.solicitante, this.facturacion});

  SolicitudFormState copyWith({
    DatosSolicitante? solicitante,
    DatosFacturacion? facturacion,
  }) => SolicitudFormState(
    solicitante: solicitante ?? this.solicitante,
    facturacion: facturacion ?? this.facturacion,
  );
}
