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

/// Primera carga / cambio de chip / refresh — la lista arranca de cero
/// (skeleton). NO se usa para "cargando más" (eso va dentro de [SeguimientoCargado]).
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
    this.finLista = false,
    this.cargandoMas = false,
    this.loadMoreError,
    this.cursorFecha,
    this.cursorIdContacto,
  });

  /// No cerrados — alimenta el badge "Seguimiento" del drawer.
  int get activos => conteos.activos;

  bool get puedePaginar =>
      !finLista && !cargandoMas && loadMoreError == null && cursorFecha != null;

  SeguimientoCargado copyWith({
    List<ContactoNegociacion>? items,
    LeadListFiltro? filtro,
    SeguimientoConteos? conteos,
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
    finLista,
    cargandoMas,
    loadMoreError,
    cursorFecha,
    cursorIdContacto,
  ];
}
