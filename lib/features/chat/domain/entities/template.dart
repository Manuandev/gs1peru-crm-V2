// lib/features/chat/domain/entities/template.dart

import 'package:app_crm/index_dependencies.dart';

class Template extends Equatable {
  final int idPlantilla;
  final String nombre;
  final int idCampania;
  final int idEvento;
  final String detalle;
  final String rutaArchivo;
  final String nombreArchivo;
  final String extensionArchivo;
  final bool isBoton;

  const Template({
    required this.idPlantilla,
    required this.nombre,
    required this.idCampania,
    required this.idEvento,
    required this.detalle,
    required this.rutaArchivo,
    required this.nombreArchivo,
    required this.extensionArchivo,
    required this.isBoton,
  });

  @override
  List<Object?> get props => [
    idPlantilla,
    nombre,
    idCampania,
    idEvento,
    detalle,
    rutaArchivo,
    nombreArchivo,
    extensionArchivo,
    isBoton,
  ];
}
