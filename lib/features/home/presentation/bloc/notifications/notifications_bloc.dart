// lib/features/home/presentation/bloc/notifications/notifications_bloc.dart
//
// Paginado por keyset (task 'LS' de CRM.CSV_NOTIFICACIONES_LST_APP,
// 2026-09-10). Mismo esquema de concurrencia que SeguimientoBloc, sin el
// paquete bloc_concurrency:
//   - "restartable" (cambio de chip / refresh): contador [_epoca]. La
//     respuesta que vuelve con una época vieja se descarta antes de emitir.
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
//
// El cambio de chip NO tumba la pantalla: si ya hay NotificationsLoaded se
// emite con recargandoLista:true (chips y contadores quedan montados).

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getData;
  final MarkNotificationsReadUseCase _markRead;

  FiltroNotificacion _filtro = FiltroNotificacion.todas;
  int _epoca = 0;
  bool _cargandoPagina = false;

  NotificationsBloc({
    required GetNotificationsUseCase getData,
    required MarkNotificationsReadUseCase markRead,
  }) : _getData = getData,
       _markRead = markRead,
       super(const NotificationsInitial()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefresh>(_onRefresh);
    on<NotificationsFiltroCambiado>(_onFiltroCambiado);
    on<NotificationsPaginaSolicitada>(_onPaginaSolicitada);
    on<NotificationsReintentarPagina>(_onReintentarPagina);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    await _cargarDesdeCero(emit);
    // Al entrar a la pantalla se marcan todas como leídas. El estado ya
    // emitido conserva el "leido" previo, así el puntito azul se ve en esta
    // visita y desaparece recién en la siguiente.
    //
    // Ojo: desde que la lista es paginada, el SP de lectura ya NO filtra
    // IB_LEIDO = 0 — si lo hiciera, este UPDATE dejaría las páginas
    // siguientes vacías (ver header de CSV_NOTIFICACIONES_LST_APP).
    unawaited(_marcarLeidas());
  }

  Future<void> _marcarLeidas() async {
    try {
      await _markRead.call();
    } catch (e, stackTrace) {
      addError(e, stackTrace);
    }
  }

  Future<void> _onRefresh(
    NotificationsRefresh event,
    Emitter<NotificationsState> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onFiltroCambiado(
    NotificationsFiltroCambiado event,
    Emitter<NotificationsState> emit,
  ) {
    if (event.filtro == _filtro && state is NotificationsLoaded) {
      return Future.value();
    }
    _filtro = event.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _cargarDesdeCero(Emitter<NotificationsState> emit) async {
    final epoca = ++_epoca;
    _cargandoPagina = false;

    final actual = state;
    if (actual is NotificationsLoaded) {
      emit(
        actual.copyWith(
          filtro: _filtro,
          recargandoLista: true,
          limpiarLoadMoreError: true,
        ),
      );
    } else {
      emit(const NotificationsLoading());
    }

    try {
      final pagina = await _getData(
        filtro: _filtro,
        cursorFecha: null,
        cursorId: null,
        tamanio: HomeRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;

      emit(
        NotificationsLoaded(
          notificaciones: pagina.items,
          filtro: _filtro,
          // Los contadores solo vienen en la primera página. Si no llegaran
          // (respuesta vacía), se conservan los que ya había en pantalla.
          conteos:
              pagina.conteos ??
              (actual is NotificationsLoaded
                  ? actual.conteos
                  : const NotificacionesConteos()),
          finLista:
              pagina.items.length < HomeRemoteDatasource.tamanioPrimera,
          cursorFecha: pagina.cursorFecha,
          cursorId: pagina.cursorId,
        ),
      );
    } on AppException catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(NotificationsError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      if (epoca != _epoca || emit.isDone) return;
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onPaginaSolicitada(
    NotificationsPaginaSolicitada event,
    Emitter<NotificationsState> emit,
  ) async {
    final s = state;
    if (s is! NotificationsLoaded) return;
    if (s.recargandoLista || s.loadMoreError != null || !s.puedePaginar) return;
    await _traerSiguiente(emit, s);
  }

  Future<void> _onReintentarPagina(
    NotificationsReintentarPagina event,
    Emitter<NotificationsState> emit,
  ) async {
    final s = state;
    if (s is! NotificationsLoaded || s.cargandoMas || s.finLista) return;
    if (s.cursorFecha == null || s.cursorId == null) return;
    await _traerSiguiente(emit, s.copyWith(limpiarLoadMoreError: true));
  }

  Future<void> _traerSiguiente(
    Emitter<NotificationsState> emit,
    NotificationsLoaded s,
  ) async {
    if (_cargandoPagina) return;
    _cargandoPagina = true;
    final epoca = _epoca;
    emit(s.copyWith(cargandoMas: true, limpiarLoadMoreError: true));

    try {
      final pagina = await _getData(
        filtro: s.filtro,
        cursorFecha: s.cursorFecha,
        cursorId: s.cursorId,
        tamanio: HomeRemoteDatasource.tamanioSiguiente,
      );
      // El chip cambió mientras cargaba → descartar esta respuesta.
      if (epoca != _epoca || emit.isDone) return;

      // Deduplicar por id y, en mensajes, TAMBIÉN por idChatCab: el SP recorta
      // por cursor antes de agrupar, así que un chat cuyo mensaje más reciente
      // ya salió en una página anterior puede volver representado por uno más
      // viejo (id distinto, mismo chat). Sin este segundo chequeo la
      // conversación aparecería dos veces en la lista.
      final idsCargados = s.notificaciones.map((n) => n.id).toSet();
      final chatsCargados = s.notificaciones
          .where((n) => n.tipo == TipoNotificacion.mensaje)
          .map((n) => n.idChatCab)
          .whereType<int>()
          .toSet();

      final nuevos = pagina.items.where((n) {
        if (idsCargados.contains(n.id)) return false;
        if (n.tipo == TipoNotificacion.mensaje && n.idChatCab != null) {
          return !chatsCargados.contains(n.idChatCab);
        }
        return true;
      }).toList();

      emit(
        s.copyWith(
          notificaciones: [...s.notificaciones, ...nuevos],
          cargandoMas: false,
          finLista:
              pagina.items.length < HomeRemoteDatasource.tamanioSiguiente,
          cursorFecha: pagina.cursorFecha ?? s.cursorFecha,
          cursorId: pagina.cursorId ?? s.cursorId,
        ),
      );
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(s.copyWith(cargandoMas: false, loadMoreError: _mensajeError(e)));
    } finally {
      _cargandoPagina = false;
    }
  }

  String _mensajeError(Object e) => e is AppException
      ? e.message
      : 'No se pudieron cargar más notificaciones.';
}
