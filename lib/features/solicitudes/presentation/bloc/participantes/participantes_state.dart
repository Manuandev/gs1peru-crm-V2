// lib/features/solicitudes/presentation/bloc/participantes/participantes_state.dart

part of 'participantes_cubit.dart';

class ParticipanteLocal {
  final int id;
  final String tipoDoc;
  final String numDoc;
  final String nombre;
  final String celular;
  final String nacionalidad;
  final String correo;
  final String cargo;
  final String tipoPago;
  final double precio;

  const ParticipanteLocal({
    required this.id,
    required this.tipoDoc,
    required this.numDoc,
    required this.nombre,
    required this.celular,
    required this.nacionalidad,
    required this.correo,
    required this.cargo,
    required this.tipoPago,
    required this.precio,
  });

  String get precioFormateado => '\$${precio.toStringAsFixed(2)}';

  ParticipanteLocal copyWith({
    int? id,
    String? tipoDoc,
    String? numDoc,
    String? nombre,
    String? celular,
    String? nacionalidad,
    String? correo,
    String? cargo,
    String? tipoPago,
    double? precio,
  }) {
    return ParticipanteLocal(
      id: id ?? this.id,
      tipoDoc: tipoDoc ?? this.tipoDoc,
      numDoc: numDoc ?? this.numDoc,
      nombre: nombre ?? this.nombre,
      celular: celular ?? this.celular,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      correo: correo ?? this.correo,
      cargo: cargo ?? this.cargo,
      tipoPago: tipoPago ?? this.tipoPago,
      precio: precio ?? this.precio,
    );
  }
}

class ParticipantesState {
  final List<ParticipanteLocal> participantes;

  const ParticipantesState({required this.participantes});

  ParticipantesState copyWith({List<ParticipanteLocal>? participantes}) =>
      ParticipantesState(participantes: participantes ?? this.participantes);

  double get totalInversion =>
      participantes.fold(0.0, (sum, p) => sum + p.precio);
}
