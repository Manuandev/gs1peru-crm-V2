// lib/features/solicitudes/presentation/bloc/form/solicitud_form_state.dart

part of 'solicitud_form_cubit.dart';

class DatosSolicitante {
  final String tipoDocId;
  final String tipoDocLabel;
  final String numDoc;
  final String nacionalidadId;
  final String nacionalidad;
  final String sexoId;
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
  final String archivoVoucherNombre;
  final String archivoOCNombre;

  const DatosSolicitante({
    this.tipoDocId = '',
    required this.tipoDocLabel,
    required this.numDoc,
    this.nacionalidadId = '',
    required this.nacionalidad,
    required this.sexoId,
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
    this.archivoVoucherNombre = '',
    this.archivoOCNombre = '',
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
  final String tipoDocId;
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
    this.tipoDocId = '',
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

  /// NUMSOL de la solicitud — vacío mientras es una creación nueva. Se
  /// setea una vez al entrar al wizard (con el NUMSOL real si se edita una
  /// solicitud existente) y se actualiza sola con el NUMSOL que devuelve el
  /// backend tras el primer guardado exitoso — así cualquier "Guardar"
  /// posterior en la misma sesión actualiza en vez de crear otra solicitud.
  /// Ver `guardarSolicitudDesdeWizard()`.
  final String numSol;
  final DatosSolicitante? solicitante;
  final DatosFacturacion? facturacion;

  const SolicitudFormState({
    this.tipoPersona = 'juridica',
    this.numSol = '',
    this.solicitante,
    this.facturacion,
  });

  String get tipoPersonaLabel =>
      tipoPersona == 'juridica' ? 'Jurídica' : 'Natural';

  SolicitudFormState copyWith({
    String? tipoPersona,
    String? numSol,
    DatosSolicitante? solicitante,
    DatosFacturacion? facturacion,
  }) => SolicitudFormState(
    tipoPersona: tipoPersona ?? this.tipoPersona,
    numSol: numSol ?? this.numSol,
    solicitante: solicitante ?? this.solicitante,
    facturacion: facturacion ?? this.facturacion,
  );
}
