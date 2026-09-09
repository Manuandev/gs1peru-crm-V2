// lib/features/cobranza/domain/entities/cobranza_filtro_avanzado.dart
//
// Filtros del panel lateral de Cobranzas (task 'LSP' de CRM.CSV_COBRANZAS_LST_APP).
// Mismo criterio que Seguimiento/Solicitudes: cada extremo de fecha tiene su
// checkbox y solo se manda al SP el que esté activo (Desde → 00:00:00, Hasta →
// 23:59:59). La fecha filtrada es CI.FC_USUARIO_C de la solicitud.
//
// Campaña → Oportunidad en cascada (sin campaña → todas; con campaña → solo las
// de esa campaña, por CRM.T_OPORTUNIDAD.ID_CAMPANIA).

import 'package:app_crm/index_dependencies.dart';

class CobranzaFiltroAvanzado extends Equatable {
  final DateTime? desde;
  final bool desdeActivo;
  final DateTime? hasta;
  final bool hastaActivo;
  final int? idCampania;
  final int? idOportunidad;

  const CobranzaFiltroAvanzado({
    this.desde,
    this.desdeActivo = false,
    this.hasta,
    this.hastaActivo = false,
    this.idCampania,
    this.idOportunidad,
  });

  /// Sin ningún filtro (todas las cobranzas, sin recorte de fecha).
  static const CobranzaFiltroAvanzado vacio = CobranzaFiltroAvanzado();

  /// Filtro por defecto: del 1 del mes actual a hoy, ambos checkboxes activos.
  /// Es lo que se aplica al entrar (salvo desde el embudo de Home) y a lo que
  /// vuelve "Limpiar".
  factory CobranzaFiltroAvanzado.porDefecto([DateTime? ahora]) {
    final n = ahora ?? DateTime.now();
    return CobranzaFiltroAvanzado(
      desde: DateTime(n.year, n.month, 1),
      desdeActivo: true,
      hasta: DateTime(n.year, n.month, n.day),
      hastaActivo: true,
    );
  }

  /// Entrando desde el embudo de Home: las MISMAS fechas del default (1 del mes
  /// actual / hoy) ya cargadas, pero con los checkboxes APAGADOS — así trae todo
  /// el histórico y, si el asesor tilda un checkbox, la fecha ya está puesta.
  factory CobranzaFiltroAvanzado.sinRango([DateTime? ahora]) =>
      CobranzaFiltroAvanzado.porDefecto(ahora)
          .copyWith(desdeActivo: false, hastaActivo: false);

  bool get activo =>
      desdeEfectivo != null ||
      hastaEfectivo != null ||
      idCampania != null ||
      idOportunidad != null;

  /// true si NO coincide con el filtro por defecto — gatea el color naranja del
  /// botón de filtro del AppBar.
  bool get esDistintoDelDefecto => this != CobranzaFiltroAvanzado.porDefecto();

  DateTime? get desdeEfectivo => (desdeActivo && desde != null)
      ? DateTime(desde!.year, desde!.month, desde!.day)
      : null;

  DateTime? get hastaEfectivo => (hastaActivo && hasta != null)
      ? DateTime(hasta!.year, hasta!.month, hasta!.day, 23, 59, 59)
      : null;

  CobranzaFiltroAvanzado copyWith({
    DateTime? desde,
    bool? desdeActivo,
    DateTime? hasta,
    bool? hastaActivo,
    int? idCampania,
    int? idOportunidad,
    bool limpiarDesde = false,
    bool limpiarHasta = false,
    bool limpiarCampania = false,
    bool limpiarOportunidad = false,
  }) {
    return CobranzaFiltroAvanzado(
      desde: limpiarDesde ? null : (desde ?? this.desde),
      desdeActivo: desdeActivo ?? this.desdeActivo,
      hasta: limpiarHasta ? null : (hasta ?? this.hasta),
      hastaActivo: hastaActivo ?? this.hastaActivo,
      idCampania: limpiarCampania ? null : (idCampania ?? this.idCampania),
      idOportunidad:
          limpiarOportunidad ? null : (idOportunidad ?? this.idOportunidad),
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
