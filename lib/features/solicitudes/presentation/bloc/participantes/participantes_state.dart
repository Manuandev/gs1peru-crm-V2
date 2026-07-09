// lib/features/solicitudes/presentation/bloc/participantes/participantes_state.dart

part of 'participantes_cubit.dart';

class ParticipanteLocal {
  final int id;
  final String tipoDoc;
  final String numDoc;
  final String nacionalidad;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String cargo;
  final String celular;
  final String tipoParticipante;
  final double importe;

  /// true cuando este registro fue generado automáticamente a partir de los
  /// datos del solicitante (switch "El solicitante será participante").
  final bool esSolicitante;

  const ParticipanteLocal({
    required this.id,
    required this.tipoDoc,
    required this.numDoc,
    required this.nacionalidad,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.cargo,
    required this.celular,
    required this.tipoParticipante,
    required this.importe,
    this.esSolicitante = false,
  });

  String get nombreCompleto => [nombres, apellidoPaterno, apellidoMaterno]
      .where((s) => s.isNotEmpty)
      .join(' ');

  String get importeFormateado => importe.toStringAsFixed(2);

  ParticipanteLocal copyWith({
    int? id,
    String? tipoDoc,
    String? numDoc,
    String? nacionalidad,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? correo,
    String? cargo,
    String? celular,
    String? tipoParticipante,
    double? importe,
    bool? esSolicitante,
  }) {
    return ParticipanteLocal(
      id: id ?? this.id,
      tipoDoc: tipoDoc ?? this.tipoDoc,
      numDoc: numDoc ?? this.numDoc,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      correo: correo ?? this.correo,
      cargo: cargo ?? this.cargo,
      celular: celular ?? this.celular,
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

  double get totalInversion =>
      participantes.fold(0.0, (sum, p) => sum + p.importe);
}
