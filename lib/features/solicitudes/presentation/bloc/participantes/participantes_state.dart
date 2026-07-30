// lib/features/solicitudes/presentation/bloc/participantes/participantes_state.dart

part of 'participantes_cubit.dart';

class ParticipanteLocal extends Equatable {
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
  // Id real del CargoItem elegido en el combo (CatalogsBloc.cargos) — nuevo
  // 2026-07-30, mismo motivo/mismo patrón que DatosSolicitante.cargoId (ver
  // solicitudes/CLAUDE.md). `cargo` sigue siendo la descripción para mostrar
  // en las cards/Resumen sin resolver contra el catálogo en cada lugar.
  final String cargoId;
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
    this.cargoId = '',
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
    String? cargoId,
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
      cargoId: cargoId ?? this.cargoId,
      celular: celular ?? this.celular,
      celularCodigoTelefono:
          celularCodigoTelefono ?? this.celularCodigoTelefono,
      tipoParticipante: tipoParticipante ?? this.tipoParticipante,
      importe: importe ?? this.importe,
      esSolicitante: esSolicitante ?? this.esSolicitante,
    );
  }

  // Extiende Equatable para poder comparar por CONTENIDO contra
  // `ParticipantesState.participantesCargado` — ver
  // `ParticipantesState.huboCambios`, mismo motivo que
  // `DatosSolicitante`/`DatosFacturacion` (`solicitud_form_state.dart`).
  @override
  List<Object?> get props => [
    id,
    tipoDocId,
    tipoDoc,
    numDoc,
    nacionalidadId,
    nacionalidad,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    correo,
    cargo,
    cargoId,
    celular,
    celularCodigoTelefono,
    tipoParticipante,
    importe,
    esSolicitante,
  ];
}

class ParticipantesState {
  final List<ParticipanteLocal> participantes;

  /// Snapshot de `participantes` tal como quedó la última vez que se cargó
  /// (task 'DT') o se guardó con éxito esta solicitud —
  /// `ParticipantesCubit.marcarSinCambios()`/`cargarParticipantes()` lo
  /// sincronizan. `huboCambios` (abajo) compara la lista ACTUAL contra este
  /// snapshot por contenido (no por identidad ni por orden — ver
  /// `_mismaLista`), así que agregar y luego quitar el mismo participante
  /// (o prender/apagar el switch "El solicitante será participante" y
  /// volver al estado original) se detecta como "sin cambios reales". Mismo
  /// patrón que `SolicitudFormState.huboCambios`.
  final List<ParticipanteLocal> participantesCargado;

  const ParticipantesState({
    required this.participantes,
    this.participantesCargado = const [],
  });

  ParticipantesState copyWith({
    List<ParticipanteLocal>? participantes,
    List<ParticipanteLocal>? participantesCargado,
  }) => ParticipantesState(
    participantes: participantes ?? this.participantes,
    participantesCargado: participantesCargado ?? this.participantesCargado,
  );

  /// true si `participantes` difiere (por contenido, sin importar el orden)
  /// de `participantesCargado`. Usado por `solicitudSinCambiosPendientes()`
  /// (`solicitud_guardar_helper.dart`).
  bool get huboCambios => !_mismaLista(participantes, participantesCargado);

  static bool _mismaLista(
    List<ParticipanteLocal> a,
    List<ParticipanteLocal> b,
  ) {
    if (a.length != b.length) return false;
    final ordenadosA = [...a]..sort((x, y) => x.id.compareTo(y.id));
    final ordenadosB = [...b]..sort((x, y) => x.id.compareTo(y.id));
    for (var i = 0; i < ordenadosA.length; i++) {
      if (ordenadosA[i] != ordenadosB[i]) return false;
    }
    return true;
  }

  /// Suma solo el importe de los participantes **Pagantes** — un Invitado
  /// no paga, así que su importe (el que se le haya puesto/sugerido, el
  /// campo sigue siendo obligatorio > 0 en el formulario) no debe contarse
  /// para el total que se muestra en el Resumen ni para lo que se factura
  /// (`DC_IMPORTE` en el CUD). Necesita el catálogo real
  /// (`CatalogsBloc.tiposParticipante`) para resolver `esInvitado` por
  /// `tipoParticipante` (id crudo, sin bool propio en `ParticipanteLocal`)
  /// — nunca comparar contra ids hardcodeados. Pedido de negocio, 2026-07-17.
  double totalPagantes(List<TipoParticipanteItem> tiposParticipante) {
    return participantes
        .where((p) {
          final tipo = tiposParticipante
              .where((t) => t.id == p.tipoParticipante)
              .firstOrNull;
          return !(tipo?.esInvitado ?? false);
        })
        .fold(0.0, (sum, p) => sum + p.importe);
  }

  /// IGV de cada participante (mapeado por `id`), calculado normal
  /// (`importe × igv%`, redondeado a 2 decimales) salvo el **último
  /// Pagante** de la lista, cuando ya se completó el máximo de
  /// participantes esperados (`cantidadEsperada`) — a ese se le asigna "lo
  /// que falta" para que la SUMA de los IGV de los Pagantes cierre exacta
  /// contra `totalPagantes × igv%` (el mismo valor que ya se manda como
  /// DC_IGV agregado, ver `SolicitudRemoteDatasource.guardarSolicitud`).
  /// Los Invitados nunca se tocan — su IGV no se factura (ver
  /// `totalPagantes`), ajustarlos no serviría de nada.
  ///
  /// Si todavía no se completó el máximo (o la solicitud no viene de una
  /// negociación con cantidad definida, `cantidadEsperada == null`), cada
  /// uno usa el cálculo normal, sin ajuste — pedido de negocio, 2026-07-22:
  /// el ajuste de centavos solo aplica al llegar al máximo, no antes.
  ///
  /// El importe (base sin IGV) de cada participante nunca se toca acá —
  /// ya no se fuerza a calzar contra ningún total (ver `_importeFijo` en
  /// `solicitud_participantes_view.dart`/`solicitud_completar_view.dart`,
  /// que ahora siempre sugiere la división simple).
  Map<int, double> igvPorParticipante(
    List<TipoParticipanteItem> tiposParticipante,
    double igvPorcentaje, {
    int? cantidadEsperada,
  }) => calcularIgvPorParticipante(
    participantes,
    tiposParticipante,
    igvPorcentaje,
    cantidadEsperada: cantidadEsperada,
  );

  /// Versión estática de [igvPorParticipante] — la usa directamente
  /// `SolicitudRemoteDatasource.guardarSolicitud`, que no tiene una
  /// instancia de `ParticipantesState` armada, solo la lista cruda que le
  /// llega por parámetro.
  static Map<int, double> calcularIgvPorParticipante(
    List<ParticipanteLocal> participantes,
    List<TipoParticipanteItem> tiposParticipante,
    double igvPorcentaje, {
    int? cantidadEsperada,
  }) {
    bool esInvitado(ParticipanteLocal p) {
      final tipo = tiposParticipante
          .where((t) => t.id == p.tipoParticipante)
          .firstOrNull;
      return tipo?.esInvitado ?? false;
    }

    final igvs = <int, double>{
      for (final p in participantes)
        p.id: double.parse(
          (p.importe * igvPorcentaje / 100).toStringAsFixed(2),
        ),
    };

    final completo =
        cantidadEsperada != null && participantes.length >= cantidadEsperada;
    if (!completo) return igvs;

    final pagantes = participantes.where((p) => !esInvitado(p)).toList();
    if (pagantes.isEmpty) return igvs;

    final ultimo = pagantes.last;
    final totalImportePagantes = pagantes.fold(
      0.0,
      (sum, p) => sum + p.importe,
    );
    final igvObjetivo = double.parse(
      (totalImportePagantes * igvPorcentaje / 100).toStringAsFixed(2),
    );
    final igvAcumulado = pagantes
        .where((p) => p.id != ultimo.id)
        .fold(0.0, (sum, p) => sum + (igvs[p.id] ?? 0));

    igvs[ultimo.id] = double.parse(
      (igvObjetivo - igvAcumulado).toStringAsFixed(2),
    );
    return igvs;
  }
}
