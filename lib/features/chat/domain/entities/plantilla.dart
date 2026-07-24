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

  // ── Campos de gestión (crear/editar plantilla) ────────────────────────────
  // No los usa el flujo de envío (SelectTemplateModal/SignalR), solo el
  // formulario de creación/edición — ver TemplateFormBloc.
  final int idCampania;
  final int idOportunidad;
  final String idEstadoNegociacion; // id de EstadoItem (catálogo general de estados)
  final bool activo;
  final bool compartir;
  final List<String> botones; // solo el texto de cada botón, sin tipos

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
    this.idCampania = 0,
    this.idOportunidad = 0,
    this.idEstadoNegociacion = '',
    this.activo = true,
    this.compartir = false,
    this.botones = const [],
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
    idCampania,
    idOportunidad,
    idEstadoNegociacion,
    activo,
    compartir,
    botones,
  ];
}
