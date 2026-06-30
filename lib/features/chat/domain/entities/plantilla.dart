// lib/features/chat/domain/entities/plantilla.dart

import 'package:app_crm/index_dependencies.dart';

class Plantilla extends Equatable {
  final int idPlantilla;
  final String nombre;
  final String idMeta;
  final String estadoMeta;
  final String contenido;
  final String archivoRuta;
  final String archivoNombre;
  final String archivoExt;
  final bool tieneBoton;

  const Plantilla({
    required this.idPlantilla,
    required this.nombre,
    required this.idMeta,
    required this.estadoMeta,
    required this.contenido,
    required this.archivoRuta,
    required this.archivoNombre,
    required this.archivoExt,
    required this.tieneBoton,
  });

  @override
  List<Object?> get props => [
    idPlantilla,
    nombre,
    idMeta,
    estadoMeta,
    contenido,
    archivoRuta,
    archivoNombre,
    archivoExt,
    tieneBoton,
  ];
}
