// lib/features/chat/domain/entities/plantilla.dart

import 'package:app_crm/index_dependencies.dart';

/// Un botón de plantilla — `idBoton` viaja de ida y vuelta con el servidor
/// para poder actualizarlo en sitio al re-guardar (`0` = nuevo, todavía sin
/// insertar) en vez de que `CSV_PLANTILLA_CUD_APP` borre y reinserte todos
/// los botones en cada guardado — ver `chat/CLAUDE.md`.
class PlantillaBoton extends Equatable {
  final int idBoton;
  final String texto;

  const PlantillaBoton({this.idBoton = 0, required this.texto});

  @override
  List<Object?> get props => [idBoton, texto];
}

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
  final List<PlantillaBoton> botones; // texto + id de cada botón, sin tipos

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

  Plantilla copyWith({
    String? archivoRuta,
    String? archivoNombre,
    String? archivoExt,
  }) => Plantilla(
    idPlantilla: idPlantilla,
    nombre: nombre,
    idMeta: idMeta,
    estadoMeta: estadoMeta,
    contenido: contenido,
    archivoRuta: archivoRuta ?? this.archivoRuta,
    archivoNombre: archivoNombre ?? this.archivoNombre,
    archivoExt: archivoExt ?? this.archivoExt,
    tieneBoton: tieneBoton,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
    idEstadoNegociacion: idEstadoNegociacion,
    activo: activo,
    compartir: compartir,
    botones: botones,
  );

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
