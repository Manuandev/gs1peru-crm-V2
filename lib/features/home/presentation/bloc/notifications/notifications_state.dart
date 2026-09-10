// lib/features/home/presentation/bloc/notifications/notifications_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  /// Filas ya descargadas — SOLO las del filtro activo. Con paginación esto
  /// nunca es el universo completo: los totales de los chips salen de
  /// [conteos], que los calcula el SP.
  final List<Notificacion> notificaciones;
  final FiltroNotificacion filtro;
  final NotificacionesConteos conteos;

  /// true mientras se recarga por cambio de chip / refresh con la lista ya
  /// visible — la cabecera se queda montada y solo la lista muestra skeleton.
  final bool recargandoLista;
  final bool cargandoMas;
  final bool finLista;
  final String? loadMoreError;

  final String? cursorFecha;
  final int? cursorId;

  const NotificationsLoaded({
    required this.notificaciones,
    required this.filtro,
    required this.conteos,
    this.recargandoLista = false,
    this.cargandoMas = false,
    this.finLista = false,
    this.loadMoreError,
    this.cursorFecha,
    this.cursorId,
  });

  bool get puedePaginar =>
      !finLista && !cargandoMas && cursorFecha != null && cursorId != null;

  NotificationsLoaded copyWith({
    List<Notificacion>? notificaciones,
    FiltroNotificacion? filtro,
    NotificacionesConteos? conteos,
    bool? recargandoLista,
    bool? cargandoMas,
    bool? finLista,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
    String? cursorFecha,
    int? cursorId,
  }) => NotificationsLoaded(
    notificaciones: notificaciones ?? this.notificaciones,
    filtro: filtro ?? this.filtro,
    conteos: conteos ?? this.conteos,
    recargandoLista: recargandoLista ?? this.recargandoLista,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    finLista: finLista ?? this.finLista,
    loadMoreError: limpiarLoadMoreError
        ? null
        : (loadMoreError ?? this.loadMoreError),
    cursorFecha: cursorFecha ?? this.cursorFecha,
    cursorId: cursorId ?? this.cursorId,
  );

  @override
  List<Object?> get props => [
    notificaciones,
    filtro,
    conteos.todas,
    conteos.actividades,
    conteos.derivaciones,
    conteos.mensajes,
    conteos.noLeidas,
    recargandoLista,
    cargandoMas,
    finLista,
    loadMoreError,
    cursorFecha,
    cursorId,
  ];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
