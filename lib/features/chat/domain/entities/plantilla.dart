// lib/features/chat/domain/entities/plantilla.dart

import 'package:app_crm/index_dependencies.dart';

class Plantilla extends Equatable {
  final int idPlantilla;
  final String nombre;
  final String contenido;
  final String nombreCampania;
  final String nombreOportunidad;
  final bool ibActivo;
  final String idMeta;
  final String estadoMeta;

  const Plantilla({
    required this.idPlantilla,
    required this.nombre,
    required this.contenido,
    required this.nombreCampania,
    required this.nombreOportunidad,
    required this.ibActivo,
    required this.idMeta,
    required this.estadoMeta,
  });

  @override
  List<Object?> get props => [
    idPlantilla,
    nombre,
    contenido,
    nombreCampania,
    nombreOportunidad,
    ibActivo,
    idMeta,
    estadoMeta,
  ];
}
