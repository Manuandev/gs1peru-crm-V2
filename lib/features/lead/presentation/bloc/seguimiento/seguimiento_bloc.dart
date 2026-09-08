// lib/features/lead/presentation/bloc/seguimiento/seguimiento_bloc.dart
//
// BLoC NUEVO para Seguimiento paginado (task 'LSP'). No comparte nada con
// LeadListBloc (que queda intacto, sin caller).
//
// Concurrencia SIN el paquete bloc_concurrency (para no tocar pubspec):
//   - "restartable" (cambio de chip / refresh): contador [_epoca]. Cada carga
//     desde cero lo incrementa; la respuesta que vuelve con una época vieja se
//     descarta antes de emitir. flutter_bloc procesa eventos concurrentemente
//     por defecto, así que el handler nuevo sí corre mientras el viejo espera.
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina]. Un
//     segundo evento de scroll mientras hay una página en vuelo se ignora.
//
// SignalR: solo llega [LeadUpdateNotifier] por ediciones de la PROPIA app
// (confirmado: no hay push por cambios de otros usuarios). Se parchea la fila
// en memoria; el estado que ya no matchea el chip activo queda hasta el
// próximo refresh (fuera de alcance de v1).

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoBloc extends Bloc<SeguimientoEvento, SeguimientoEstado> {
  final GetSeguimientoPaginaUseCase _getPagina;

  LeadListFiltro _filtro;
  int _epoca = 0;
  bool _cargandoPagina = false;
  StreamSubscription<LeadUpdate>? _updateSub;

  SeguimientoBloc(
    this._getPagina, {
    LeadListFiltro? filtroInicial,
  }) : _filtro = filtroInicial ?? LeadListFiltro.todos,
       super(const SeguimientoInicial()) {
    on<SeguimientoIniciado>(_onIniciado);
    on<SeguimientoRefrescado>(_onRefrescado);
    on<SeguimientoFiltroCambiado>(_onFiltroCambiado);
    on<SeguimientoPaginaSolicitada>(_onPaginaSolicitada);
    on<SeguimientoReintentarPagina>(_onReintentarPagina);
    on<SeguimientoLeadActualizado>(_onLeadActualizado);

    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final negociacion = update.updatedLead;
      if (!isClosed && negociacion is Negociacion) {
        add(SeguimientoLeadActualizado(negociacion));
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
  }

  // ── Carga desde cero (primera vez / refresh / cambio de chip) ───────────────

  Future<void> _onIniciado(
    SeguimientoIniciado event,
    Emitter<SeguimientoEstado> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onRefrescado(
    SeguimientoRefrescado event,
    Emitter<SeguimientoEstado> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onFiltroCambiado(
    SeguimientoFiltroCambiado event,
    Emitter<SeguimientoEstado> emit,
  ) {
    if (event.filtro == _filtro && state is SeguimientoCargado) return Future.value();
    _filtro = event.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _cargarDesdeCero(Emitter<SeguimientoEstado> emit) async {
    final epoca = ++_epoca;
    _cargandoPagina = false;
    emit(const SeguimientoCargando());

    try {
      final pagina = await _getPagina(
        filtro: _filtro,
        cursorFecha: null,
        cursorIdContacto: null,
        tamanio: SeguimientoRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;

      emit(
        SeguimientoCargado(
          items: pagina.items,
          filtro: _filtro,
          conteos: pagina.conteos ?? const SeguimientoConteos(),
          finLista:
              pagina.items.length < SeguimientoRemoteDatasource.tamanioPrimera,
          cursorFecha: pagina.cursorFecha,
          cursorIdContacto: pagina.cursorIdContacto,
        ),
      );
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(SeguimientoErrorInicial(_mensajeError(e)));
    }
  }

  // ── Página siguiente ───────────────────────────────────────────────────────

  Future<void> _onPaginaSolicitada(
    SeguimientoPaginaSolicitada event,
    Emitter<SeguimientoEstado> emit,
  ) async {
    final s = state;
    if (s is! SeguimientoCargado) return;
    // Con el pie en error, el scroll NO vuelve a disparar solo — hay que tocar
    // "Reintentar" (SeguimientoReintentarPagina).
    if (s.loadMoreError != null || !s.puedePaginar) return;
    await _traerSiguiente(emit, s);
  }

  Future<void> _onReintentarPagina(
    SeguimientoReintentarPagina event,
    Emitter<SeguimientoEstado> emit,
  ) async {
    final s = state;
    if (s is! SeguimientoCargado || s.cargandoMas || s.finLista) return;
    if (s.cursorFecha == null) return;
    await _traerSiguiente(emit, s.copyWith(limpiarLoadMoreError: true));
  }

  Future<void> _traerSiguiente(
    Emitter<SeguimientoEstado> emit,
    SeguimientoCargado s,
  ) async {
    if (_cargandoPagina) return;
    _cargandoPagina = true;
    final epoca = _epoca;
    emit(s.copyWith(cargandoMas: true, limpiarLoadMoreError: true));

    try {
      final pagina = await _getPagina(
        filtro: s.filtro,
        cursorFecha: s.cursorFecha,
        cursorIdContacto: s.cursorIdContacto,
        tamanio: SeguimientoRemoteDatasource.tamanioSiguiente,
      );
      // El chip cambió mientras cargaba → descartar esta respuesta.
      if (epoca != _epoca || emit.isDone) return;

      // Deduplicar por ID_CONTACTO: el keyset no repite por paginación, pero un
      // contacto ya cargado puede volver a aparecer si subió de posición por
      // actividad nueva.
      final idsCargados = s.items
          .map((c) => c.contacto.idContacto)
          .toSet();
      final nuevos = pagina.items
          .where((c) => !idsCargados.contains(c.contacto.idContacto))
          .toList();

      emit(
        s.copyWith(
          items: [...s.items, ...nuevos],
          cargandoMas: false,
          finLista: pagina.items.length <
              SeguimientoRemoteDatasource.tamanioSiguiente,
          cursorFecha: pagina.cursorFecha ?? s.cursorFecha,
          cursorIdContacto: pagina.cursorIdContacto ?? s.cursorIdContacto,
        ),
      );
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(s.copyWith(cargandoMas: false, loadMoreError: _mensajeError(e)));
    } finally {
      _cargandoPagina = false;
    }
  }

  // ── Parche por edición local ───────────────────────────────────────────────

  void _onLeadActualizado(
    SeguimientoLeadActualizado event,
    Emitter<SeguimientoEstado> emit,
  ) {
    final s = state;
    if (s is! SeguimientoCargado) return;

    final items = s.items
        .map(
          (c) => c.contacto.idContacto == event.negociacion.idContacto
              ? c.copyWith(negociacion: event.negociacion)
              : c,
        )
        .toList();
    emit(s.copyWith(items: items));
  }

  String _mensajeError(Object e) =>
      e is AppException ? e.message : 'No se pudo cargar el seguimiento.';
}
