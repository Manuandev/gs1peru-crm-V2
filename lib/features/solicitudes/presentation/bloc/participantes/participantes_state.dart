// lib/features/solicitudes/presentation/bloc/participantes/participantes_state.dart

part of 'participantes_cubit.dart';

class ParticipanteLocal {
  final int id;
  final String tipoDocId;
  final String tipoDoc;
  final String numDoc;
  final String nacionalidadId;
  final String nacionalidad;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String cargo;
  final String celular;
  final String celularCodigoTelefono;
  final String tipoParticipante;
  final double importe;

  /// true cuando este registro fue generado automáticamente a partir de los
  /// datos del solicitante (switch "El solicitante será participante").
  final bool esSolicitante;

  const ParticipanteLocal({
    required this.id,
    this.tipoDocId = '',
    required this.tipoDoc,
    required this.numDoc,
    this.nacionalidadId = '',
    required this.nacionalidad,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.cargo,
    required this.celular,
    this.celularCodigoTelefono = '',
    required this.tipoParticipante,
    required this.importe,
    this.esSolicitante = false,
  });

  String get nombreCompleto => [
    nombres,
    apellidoPaterno,
    apellidoMaterno,
  ].where((s) => s.isNotEmpty).join(' ');

  String get importeFormateado => importe.toStringAsFixed(2);

  ParticipanteLocal copyWith({
    int? id,
    String? tipoDocId,
    String? tipoDoc,
    String? numDoc,
    String? nacionalidadId,
    String? nacionalidad,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? correo,
    String? cargo,
    String? celular,
    String? celularCodigoTelefono,
    String? tipoParticipante,
    double? importe,
    bool? esSolicitante,
  }) {
    return ParticipanteLocal(
      id: id ?? this.id,
      tipoDocId: tipoDocId ?? this.tipoDocId,
      tipoDoc: tipoDoc ?? this.tipoDoc,
      numDoc: numDoc ?? this.numDoc,
      nacionalidadId: nacionalidadId ?? this.nacionalidadId,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      correo: correo ?? this.correo,
      cargo: cargo ?? this.cargo,
      celular: celular ?? this.celular,
      celularCodigoTelefono:
          celularCodigoTelefono ?? this.celularCodigoTelefono,
      tipoParticipante: tipoParticipante ?? this.tipoParticipante,
      importe: importe ?? this.importe,
      esSolicitante: esSolicitante ?? this.esSolicitante,
    );
  }
}

class ParticipantesState {
  final List<ParticipanteLocal> participantes;

  const ParticipantesState({required this.participantes});

  ParticipantesState copyWith({List<ParticipanteLocal>? participantes}) =>
      ParticipantesState(participantes: participantes ?? this.participantes);

  /// Suma solo el importe de los participantes **Pagantes** — un Invitado
  /// no paga, así que su importe (el que se le haya puesto/sugerido, el
  /// campo sigue siendo obligatorio > 0 en el formulario) no debe contarse
  /// para el total que se muestra en el Resumen ni para lo que se factura
  /// (`DC_IMPORTE` en el CUD). Necesita el catálogo real
  /// (`CatalogsBloc.tiposParticipante`) para resolver `esInvitado` por
  /// `tipoParticipante` (id crudo, sin bool propio en `ParticipanteLocal`)
  /// — nunca comparar contra ids hardcodeados. Pedido de negocio, 2026-07-17.
  double totalPagantes(List<TipoParticipanteItem> tiposParticipante) {
    return participantes.where((p) {
      final tipo = tiposParticipante
          .where((t) => t.id == p.tipoParticipante)
          .firstOrNull;
      return !(tipo?.esInvitado ?? false);
    }).fold(0.0, (sum, p) => sum + p.importe);
  }
}
