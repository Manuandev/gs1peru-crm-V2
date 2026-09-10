// lib/features/solicitudes/domain/entities/solicitud_filtro_avanzado.dart
//
// Filtros del panel lateral de Solicitudes (task 'LSP' de CRM.CSV_SOLICITUD_LST_APP).
// Cada extremo de fecha tiene su propio checkbox: solo se manda al SP el que
// esté activo (Desde → 00:00:00, Hasta → 23:59:59). Filtra FC_USUARIO_C
// (creación) de la solicitud, igual que la web. Campaña → Oportunidad en
// cascada: ambos salen de CRM.T_OPORTUNIDAD (OP.ID_CAMPANIA / OP.ID_OPORTUNIDAD)
// y la oportunidad se recorta a las de la campaña elegida. Evento
// (EVT.T_EVENTO) ya no participa — mismo criterio que la web.

import 'package:app_crm/index_dependencies.dart';

class SolicitudFiltroAvanzado extends Equatable {
  final DateTime? desde;
  final bool desdeActivo;
  final DateTime? hasta;
  final bool hastaActivo;
  final int? idCampania;
  final int? idOportunidad;

  const SolicitudFiltroAvanzado({
    this.desde,
    this.desdeActivo = false,
    this.hasta,
    this.hastaActivo = false,
    this.idCampania,
    this.idOportunidad,
  });

  static const SolicitudFiltroAvanzado vacio = SolicitudFiltroAvanzado();

  /// Filtro por defecto: del 1 del mes actual a hoy, ambos activos — igual que
  /// la web ("Solicitud registro ficha"). Es lo que se aplica al entrar y a lo
  /// que vuelve "Limpiar".
  factory SolicitudFiltroAvanzado.porDefecto([DateTime? ahora]) {
    final n = ahora ?? DateTime.now();
    return SolicitudFiltroAvanzado(
      desde: DateTime(n.year, n.month, 1),
      desdeActivo: true,
      hasta: DateTime(n.year, n.month, n.day),
      hastaActivo: true,
    );
  }

  bool get activo =>
      desdeEfectivo != null ||
      hastaEfectivo != null ||
      idCampania != null ||
      idOportunidad != null;

  bool get esDistintoDelDefecto => this != SolicitudFiltroAvanzado.porDefecto();

  DateTime? get desdeEfectivo => (desdeActivo && desde != null)
      ? DateTime(desde!.year, desde!.month, desde!.day)
      : null;

  DateTime? get hastaEfectivo => (hastaActivo && hasta != null)
      ? DateTime(hasta!.year, hasta!.month, hasta!.day, 23, 59, 59)
      : null;

  SolicitudFiltroAvanzado copyWith({
    DateTime? desde,
    bool? desdeActivo,
    DateTime? hasta,
    bool? hastaActivo,
    int? idCampania,
    int? idOportunidad,
    bool limpiarCampania = false,
    bool limpiarOportunidad = false,
  }) {
    return SolicitudFiltroAvanzado(
      desde: desde ?? this.desde,
      desdeActivo: desdeActivo ?? this.desdeActivo,
      hasta: hasta ?? this.hasta,
      hastaActivo: hastaActivo ?? this.hastaActivo,
      idCampania: limpiarCampania ? null : (idCampania ?? this.idCampania),
      idOportunidad: limpiarOportunidad ? null : (idOportunidad ?? this.idOportunidad),
    );
  }

  @override
  List<Object?> get props => [
    desde,
    desdeActivo,
    hasta,
    hastaActivo,
    idCampania,
    idOportunidad,
  ];
}
