// lib/features/lead/domain/entities/seguimiento_filtro_avanzado.dart
//
// Filtros del panel lateral de Seguimiento (task 'LSP' de CRM.CSV_LEADS_LST_APP).
// Cada extremo de fecha tiene su propio checkbox: solo se manda al SP el que
// esté activo (Desde → 00:00:00, Hasta → 23:59:59). La fecha filtrada es
// FC_ULTIMA = última interacción (modificación, o creación si nunca se modificó)
// de la negociación, o del propio contacto si no tiene ninguna.
//
// Estado/Subestado quedan RESERVADOS: el SP ya parsea sus campos pero su WHERE
// está comentado — el estado lo maneja el chip de arriba (Todos/Nuevos/En
// desarrollo/Propuesta). Cuando se activen, agregar aquí y en el drawer.

import 'package:app_crm/index_dependencies.dart';

class SeguimientoFiltroAvanzado extends Equatable {
  /// Fecha "desde" elegida (sin hora). Solo aplica si [desdeActivo].
  final DateTime? desde;
  final bool desdeActivo;

  /// Fecha "hasta" elegida (sin hora). Solo aplica si [hastaActivo].
  final DateTime? hasta;
  final bool hastaActivo;

  final int? idCampania;
  final int? idOportunidad;

  const SeguimientoFiltroAvanzado({
    this.desde,
    this.desdeActivo = false,
    this.hasta,
    this.hastaActivo = false,
    this.idCampania,
    this.idOportunidad,
  });

  /// Sin ningún filtro (todos los contactos, sin recorte de fecha).
  static const SeguimientoFiltroAvanzado vacio = SeguimientoFiltroAvanzado();

  /// Filtro por defecto de Seguimiento (igual que la web "Gestión de
  /// prospectos"): del **1 del mes actual** a **hoy**, ambos checkboxes
  /// activos. Es lo que se aplica al entrar a la pantalla y a lo que vuelve
  /// "Limpiar". Se calcula con [ahora] (default `DateTime.now()`).
  factory SeguimientoFiltroAvanzado.porDefecto([DateTime? ahora]) {
    final n = ahora ?? DateTime.now();
    return SeguimientoFiltroAvanzado(
      desde: DateTime(n.year, n.month, 1),
      desdeActivo: true,
      hasta: DateTime(n.year, n.month, n.day),
      hastaActivo: true,
    );
  }

  /// Entrando desde el embudo de Home: las MISMAS fechas del default (1 del mes
  /// actual / hoy) ya cargadas, pero con los checkboxes APAGADOS — trae todo el
  /// histórico y, si el asesor tilda un checkbox, la fecha ya está puesta.
  factory SeguimientoFiltroAvanzado.sinRango([DateTime? ahora]) =>
      SeguimientoFiltroAvanzado.porDefecto(ahora)
          .copyWith(desdeActivo: false, hastaActivo: false);

  /// true si hay al menos un filtro que efectivamente recorta la lista.
  bool get activo => desdeEfectivo != null || hastaEfectivo != null || idCampania != null || idOportunidad != null;

  /// true si NO coincide con el filtro por defecto (mes actual → hoy) — gatea el
  /// color del botón de filtro en el AppBar (naranja solo si el asesor lo cambió).
  bool get esDistintoDelDefecto =>
      this != SeguimientoFiltroAvanzado.porDefecto();

  /// Límite inferior real que se manda al SP (00:00:00 del día elegido), o null
  /// si el checkbox está apagado.
  DateTime? get desdeEfectivo => (desdeActivo && desde != null)
      ? DateTime(desde!.year, desde!.month, desde!.day)
      : null;

  /// Límite superior real que se manda al SP (23:59:59 del día elegido), o null
  /// si el checkbox está apagado.
  DateTime? get hastaEfectivo => (hastaActivo && hasta != null)
      ? DateTime(hasta!.year, hasta!.month, hasta!.day, 23, 59, 59)
      : null;

  SeguimientoFiltroAvanzado copyWith({
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
    return SeguimientoFiltroAvanzado(
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
