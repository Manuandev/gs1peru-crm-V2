// lib/features/solicitudes/presentation/bloc/form/solicitud_form_state.dart

part of 'solicitud_form_cubit.dart';

class DatosSolicitante {
  final String tipoDocLabel;
  final String numDoc;
  final String nacionalidad;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String cargo;
  final String celular;
  final String celularCodigoTelefono;
  final String correo;
  final int? canalId;
  final String canalNombre;
  final String ruc;
  final String razonSocial;
  final bool solicitanteEsParticipante;
  final bool facturarAlSolicitante;

  const DatosSolicitante({
    required this.tipoDocLabel,
    required this.numDoc,
    required this.nacionalidad,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.cargo,
    required this.celular,
    this.celularCodigoTelefono = '',
    required this.correo,
    this.canalId,
    required this.canalNombre,
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

  String get canalTexto => canalNombre.isEmpty ? '—' : canalNombre;
}

class DatosFacturacion {
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
  final String celularCodigoTelefono;
  final String correo;
  final String direccion;
  final String actividadEconomica;
  final String nit;
  final String observaciones;

  const DatosFacturacion({
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
    this.celularCodigoTelefono = '',
    required this.correo,
    required this.direccion,
    required this.actividadEconomica,
    required this.nit,
    required this.observaciones,
  });
}

class SolicitudFormState {
  /// 'juridica' | 'natural' — compartido por los pasos 1 (solicitante) y 3
  /// (facturación): ambos representan el mismo dato, no dos independientes.
  final String tipoPersona;
  final DatosSolicitante? solicitante;
  final DatosFacturacion? facturacion;

  const SolicitudFormState({
    this.tipoPersona = 'juridica',
    this.solicitante,
    this.facturacion,
  });

  String get tipoPersonaLabel =>
      tipoPersona == 'juridica' ? 'Jurídica' : 'Natural';

  SolicitudFormState copyWith({
    String? tipoPersona,
    DatosSolicitante? solicitante,
    DatosFacturacion? facturacion,
  }) => SolicitudFormState(
    tipoPersona: tipoPersona ?? this.tipoPersona,
    solicitante: solicitante ?? this.solicitante,
    facturacion: facturacion ?? this.facturacion,
  );
}
