// lib/features/lead/presentation/bloc/seguimiento/seguimiento_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

sealed class SeguimientoEstado extends Equatable {
  const SeguimientoEstado();

  @override
  List<Object?> get props => [];
}

class SeguimientoInicial extends SeguimientoEstado {
  const SeguimientoInicial();
}

/// SOLO la primera carga de la pantalla (aún no hay chips ni contadores que
/// mostrar) → skeleton completo. El cambio de chip / aplicar filtro / refresh
/// NO pasan por acá: se resuelven con [SeguimientoCargado.recargandoLista] para
/// no desmontar chips y contadores.
class SeguimientoCargando extends SeguimientoEstado {
  const SeguimientoCargando();
}

/// Falla en la PRIMERA carga (la lista todavía está vacía). Un fallo de página
/// siguiente NO llega acá — se muestra en el pie vía [SeguimientoCargado.loadMoreError].
class SeguimientoErrorInicial extends SeguimientoEstado {
  final String mensaje;
  const SeguimientoErrorInicial(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class SeguimientoCargado extends SeguimientoEstado {
  final List<ContactoNegociacion> items;
  final LeadListFiltro filtro;
  final SeguimientoConteos conteos;
  final SeguimientoFiltroAvanzado filtroAvanzado;

  /// Texto de búsqueda aplicado ('' = sin búsqueda). Solo lo lee la vista
  /// (mensaje de "sin resultados"); la fuente de verdad es el bloc.
  final String busqueda;

  /// Recarga desde cero en curso (cambio de chip / aplicar filtro del panel /
  /// refresh) manteniendo chips y contadores montados — solo el área de la
  /// lista muestra el skeleton. Distinto de [SeguimientoCargando] (pantalla
  /// completa, primera carga).
  final bool recargandoLista;

  /// true cuando la última página vino con menos filas que el tamaño pedido.
  final bool finLista;

  /// Hay una página siguiente en vuelo (pie con spinner).
  final bool cargandoMas;

  /// Falló la última página siguiente — pie con mensaje + "Reintentar". Distinto
  /// de [SeguimientoErrorInicial]: la lista de arriba queda intacta.
  final String? loadMoreError;

  /// Cursor keyset para la próxima página (de la última fila cargada).
  final String? cursorFecha;
  final int? cursorIdContacto;

  const SeguimientoCargado({
    required this.items,
    required this.filtro,
    required this.conteos,
    this.filtroAvanzado = SeguimientoFiltroAvanzado.vacio,
    this.busqueda = '',
    this.recargandoLista = false,
    this.finLista = false,
    this.cargandoMas = false,
    this.loadMoreError,
    this.cursorFecha,
    this.cursorIdContacto,
  });

  /// No cerrados — alimenta el badge "Seguimiento" del drawer. Número global
  /// (el SP lo calcula sin aplicar el filtro del panel).
  int get activos => conteos.activos;

  /// El botón de filtro del AppBar se pinta naranja solo si el asesor cambió el
  /// filtro respecto al default (mes actual → hoy) — no por el default en sí.
  bool get tieneFiltroAvanzado => filtroAvanzado.esDistintoDelDefecto;

  bool get puedePaginar =>
      !finLista && !cargandoMas && loadMoreError == null && cursorFecha != null;

  SeguimientoCargado copyWith({
    List<ContactoNegociacion>? items,
    LeadListFiltro? filtro,
    SeguimientoConteos? conteos,
    SeguimientoFiltroAvanzado? filtroAvanzado,
    String? busqueda,
    bool? recargandoLista,
    bool? finLista,
    bool? cargandoMas,
    String? cursorFecha,
    int? cursorIdContacto,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
  }) {
    return SeguimientoCargado(
      items: items ?? this.items,
      filtro: filtro ?? this.filtro,
      conteos: conteos ?? this.conteos,
      filtroAvanzado: filtroAvanzado ?? this.filtroAvanzado,
      busqueda: busqueda ?? this.busqueda,
      recargandoLista: recargandoLista ?? this.recargandoLista,
      finLista: finLista ?? this.finLista,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      loadMoreError: limpiarLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
      cursorFecha: cursorFecha ?? this.cursorFecha,
      cursorIdContacto: cursorIdContacto ?? this.cursorIdContacto,
    );
  }

  @override
  List<Object?> get props => [
    items,
    filtro,
    conteos.comoMapa,
    conteos.activos,
    filtroAvanzado,
    busqueda,
    recargandoLista,
    finLista,
    cargandoMas,
    loadMoreError,
    cursorFecha,
    cursorIdContacto,
  ];
}
