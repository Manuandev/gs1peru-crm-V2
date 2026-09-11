// lib/features/lead/presentation/bloc/seguimiento/seguimiento_bloc.dart
//
// BLoC NUEVO para Seguimiento paginado (task 'LSP'). No comparte nada con
// LeadListBloc (que queda intacto, sin caller).
//
// Concurrencia SIN el paquete bloc_concurrency (para no tocar pubspec):
//   - "restartable" (cambio de chip / refresh / filtro del panel / búsqueda):
//     contador [_epoca]. Cada carga desde cero lo incrementa; la respuesta que
//     vuelve con una época vieja se descarta antes de emitir.
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
//   - "debounce" (buscador del AppBar): ticket [_ticketBusqueda], mismo estilo
//     que [_epoca] — cada tecla saca uno nuevo y tras la espera solo sigue el
//     último.
//
// Cambio de chip / aplicar filtro NO tumban la pantalla: si ya hay
// SeguimientoCargado, se emite con recargandoLista:true (chips + contadores
// quedan montados, solo la lista muestra skeleton). El skeleton completo
// (SeguimientoCargando) es solo la primera carga.
//
// SignalR: solo llega [LeadUpdateNotifier] por ediciones de la PROPIA app.

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoBloc extends Bloc<SeguimientoEvento, SeguimientoEstado> {
  final GetSeguimientoPaginaUseCase _getPagina;

  LeadListFiltro _filtro;
  // Al entrar, Seguimiento arranca con el filtro por defecto (mes actual → hoy,
  // ambos activos), igual que la web. "Limpiar" vuelve a esto, no a vacío.
  // Excepción: entrando desde el embudo de Home (sinRangoFecha:true) arranca
  // SIN rango de fechas, para que la lista cuadre con los totales de Home.
  SeguimientoFiltroAvanzado _filtroAvanzado;
  // Texto del buscador ya normalizado ('' = sin búsqueda). Se combina con chip
  // + panel (AND en el SP) y viaja en TODAS las páginas — ver [_pedirPagina].
  String _busqueda = '';
  int _ticketBusqueda = 0;
  int _epoca = 0;
  bool _cargandoPagina = false;
  StreamSubscription<LeadUpdate>? _updateSub;

  SeguimientoBloc(
    this._getPagina, {
    LeadListFiltro? filtroInicial,
    bool sinRangoFecha = false,
  }) : _filtro = filtroInicial ?? LeadListFiltro.todos,
       _filtroAvanzado = sinRangoFecha
           ? SeguimientoFiltroAvanzado.sinRango()
           : SeguimientoFiltroAvanzado.porDefecto(),
       super(const SeguimientoInicial()) {
    on<SeguimientoIniciado>(_onIniciado);
    on<SeguimientoRefrescado>(_onRefrescado);
    on<SeguimientoFiltroCambiado>(_onFiltroCambiado);
    on<SeguimientoFiltroAvanzadoAplicado>(_onFiltroAvanzadoAplicado);
    on<SeguimientoFiltroAvanzadoLimpiado>(_onFiltroAvanzadoLimpiado);
    on<SeguimientoBusquedaCambiada>(_onBusquedaCambiada);
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

  // ── Carga desde cero (primera vez / refresh / cambio de chip / filtro) ──────

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
    if (event.filtro == _filtro && state is SeguimientoCargado) {
      return Future.value();
    }
    _filtro = event.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoAplicado(
    SeguimientoFiltroAvanzadoAplicado event,
    Emitter<SeguimientoEstado> emit,
  ) {
    _filtroAvanzado = event.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoLimpiado(
    SeguimientoFiltroAvanzadoLimpiado event,
    Emitter<SeguimientoEstado> emit,
  ) {
    // "Limpiar" vuelve al filtro por defecto (mes actual → hoy), no a vacío.
    // Para ver todo el histórico, el asesor destilda los checkboxes a mano.
    final defecto = SeguimientoFiltroAvanzado.porDefecto();
    if (_filtroAvanzado == defecto && state is SeguimientoCargado) {
      return Future.value();
    }
    _filtroAvanzado = defecto;
    return _cargarDesdeCero(emit);
  }

  // ── Búsqueda (buscador del AppBar) ─────────────────────────────────────────

  Future<void> _onBusquedaCambiada(
    SeguimientoBusquedaCambiada event,
    Emitter<SeguimientoEstado> emit,
  ) async {
    final texto = event.texto.trim();

    // Debounce: cada tecla saca un ticket; tras la espera solo sigue la última.
    // Vacío (la X del buscador) limpia al toque, sin esperar.
    final ticket = ++_ticketBusqueda;
    if (texto.isNotEmpty) await Future.delayed(AppConstants.debounceBusqueda);
    if (ticket != _ticketBusqueda || isClosed || emit.isDone) return;

    // Por debajo del mínimo de caracteres no filtra (con 1-2 letras traería
    // media base y no aporta).
    final busqueda = texto.length >= AppConstants.busquedaMinCaracteres
        ? texto
        : '';
    if (busqueda == _busqueda && state is SeguimientoCargado) return;
    _busqueda = busqueda;
    await _cargarDesdeCero(emit);
  }

  Future<void> _cargarDesdeCero(Emitter<SeguimientoEstado> emit) async {
    final epoca = ++_epoca;
    _cargandoPagina = false;

    final actual = state;
    if (actual is SeguimientoCargado) {
      // Cambio de chip / filtro / refresh con lista ya visible → solo la lista
      // muestra skeleton; chips y contadores se quedan.
      emit(actual.copyWith(recargandoLista: true, limpiarLoadMoreError: true));
    } else {
      emit(const SeguimientoCargando());
    }

    try {
      final pagina = await _pedirPagina(
        filtro: _filtro,
        tamanio: SeguimientoRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;

      emit(
        SeguimientoCargado(
          items: pagina.items,
          filtro: _filtro,
          conteos: pagina.conteos ?? const SeguimientoConteos(),
          filtroAvanzado: _filtroAvanzado,
          busqueda: _busqueda,
          recargandoLista: false,
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

  /// Único punto que arma la consulta al SP: chip + panel + búsqueda viajan
  /// juntos en TODAS las páginas. Si una página siguiente saliera sin alguno,
  /// mezclaría filas filtradas con sin filtrar (el cursor keyset solo vale
  /// para la misma combinación de filtros).
  Future<SeguimientoPagina> _pedirPagina({
    required LeadListFiltro filtro,
    String? cursorFecha,
    int? cursorIdContacto,
    required int tamanio,
  }) => _getPagina(
    filtro: filtro,
    cursorFecha: cursorFecha,
    cursorIdContacto: cursorIdContacto,
    tamanio: tamanio,
    fcDesde: _filtroAvanzado.desdeEfectivo,
    fcHasta: _filtroAvanzado.hastaEfectivo,
    idCampania: _filtroAvanzado.idCampania,
    idOportunidad: _filtroAvanzado.idOportunidad,
    busqueda: _busqueda,
  );

  // ── Página siguiente ───────────────────────────────────────────────────────

  Future<void> _onPaginaSolicitada(
    SeguimientoPaginaSolicitada event,
    Emitter<SeguimientoEstado> emit,
  ) async {
    final s = state;
    if (s is! SeguimientoCargado) return;
    if (s.recargandoLista) return;
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
      final pagina = await _pedirPagina(
        filtro: s.filtro,
        cursorFecha: s.cursorFecha,
        cursorIdContacto: s.cursorIdContacto,
        tamanio: SeguimientoRemoteDatasource.tamanioSiguiente,
      );
      // El chip / filtro cambió mientras cargaba → descartar esta respuesta.
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

  Future<void> _onLeadActualizado(
    SeguimientoLeadActualizado event,
    Emitter<SeguimientoEstado> emit,
  ) async {
    final s = state;
    if (s is! SeguimientoCargado) return;

    // 1) Parche instantáneo de la fila ya visible (sin esperar a la red).
    final items = s.items
        .map(
          (c) => c.contacto.idContacto == event.negociacion.idContacto
              ? c.copyWith(negociacion: event.negociacion)
              : c,
        )
        .toList();
    emit(s.copyWith(items: items));

    // 2) Recarga silenciosa de la página 1. El parche de arriba no alcanza:
    //    los contadores (Nuevos/En desarrollo/Propuesta) y el "N negociaciones"
    //    de cada card (totalLeads = CL.CT_LEADS) vienen del SP y no se pueden
    //    recalcular en cliente, y una negociación recién creada puede sumar un
    //    contacto que no estaba en la lista. No se muestra skeleton: la lista
    //    parcheada se queda hasta que llega la respuesta. Vuelve a la página 1
    //    (se pierde el scroll más allá de la 1ª página) — es el único modo de
    //    traer contadores/badge frescos.
    final epoca = ++_epoca;
    _cargandoPagina = false;
    try {
      final pagina = await _pedirPagina(
        filtro: _filtro,
        tamanio: SeguimientoRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;
      emit(
        SeguimientoCargado(
          items: pagina.items,
          filtro: _filtro,
          conteos: pagina.conteos ?? const SeguimientoConteos(),
          filtroAvanzado: _filtroAvanzado,
          busqueda: _busqueda,
          recargandoLista: false,
          finLista:
              pagina.items.length < SeguimientoRemoteDatasource.tamanioPrimera,
          cursorFecha: pagina.cursorFecha,
          cursorIdContacto: pagina.cursorIdContacto,
        ),
      );
    } catch (_) {
      // Recarga silenciosa: si falla, se queda la lista parcheada, sin ruido.
    }
  }

  String _mensajeError(Object e) =>
      e is AppException ? e.message : 'No se pudo cargar el seguimiento.';
}
