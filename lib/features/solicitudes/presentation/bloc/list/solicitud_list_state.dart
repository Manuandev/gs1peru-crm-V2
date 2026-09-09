// lib/features/solicitudes/presentation/bloc/list/solicitud_list_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

abstract class SolicitudListState extends Equatable {
  const SolicitudListState();

  @override
  List<Object?> get props => [];
}

class SolicitudListInitial extends SolicitudListState {
  const SolicitudListInitial();
}

/// SOLO la primera carga → skeleton completo. El cambio de chip / filtro /
/// refresh se resuelve con [SolicitudListSuccess.recargandoLista].
class SolicitudListLoading extends SolicitudListState {
  const SolicitudListLoading();
}

class SolicitudListError extends SolicitudListState {
  final String message;
  const SolicitudListError(this.message);

  @override
  List<Object?> get props => [message];
}

class SolicitudListSuccess extends SolicitudListState {
  /// Filas ya filtradas por búsqueda de texto (cliente, sobre las páginas
  /// cargadas). La lista completa cargada vive en el bloc (`_items`).
  final List<Solicitud> solicitudes;
  final SolicitudFiltro filtro;
  final String? asesorSeleccionado;
  final SolicitudFiltroAvanzado filtroAvanzado;

  /// Contadores desde BD (1ª página) — aplican el filtro del panel, no el chip.
  final int cntSinValidar;
  final int cntValidados;

  /// Best-effort sobre las páginas cargadas — alimenta el picker de "Asesores".
  final Map<String, Map<bool, int>> conteosPorAsesor;

  final bool recargandoLista;
  final bool finLista;
  final bool cargandoMas;
  final String? loadMoreError;
  final String? cursorFecha;
  final String? cursorNumsol;

  const SolicitudListSuccess({
    required this.solicitudes,
    this.filtro = SolicitudFiltro.todas,
    this.asesorSeleccionado,
    this.filtroAvanzado = SolicitudFiltroAvanzado.vacio,
    this.cntSinValidar = 0,
    this.cntValidados = 0,
    this.conteosPorAsesor = const {},
    this.recargandoLista = false,
    this.finLista = false,
    this.cargandoMas = false,
    this.loadMoreError,
    this.cursorFecha,
    this.cursorNumsol,
  });

  bool get tieneFiltroAvanzado => filtroAvanzado.esDistintoDelDefecto;

  bool get puedePaginar =>
      !finLista && !cargandoMas && loadMoreError == null && cursorFecha != null;

  SolicitudListSuccess copyWith({
    List<Solicitud>? solicitudes,
    SolicitudFiltro? filtro,
    String? asesorSeleccionado,
    SolicitudFiltroAvanzado? filtroAvanzado,
    int? cntSinValidar,
    int? cntValidados,
    Map<String, Map<bool, int>>? conteosPorAsesor,
    bool? recargandoLista,
    bool? finLista,
    bool? cargandoMas,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
    String? cursorFecha,
    String? cursorNumsol,
  }) {
    return SolicitudListSuccess(
      solicitudes: solicitudes ?? this.solicitudes,
      filtro: filtro ?? this.filtro,
      asesorSeleccionado: asesorSeleccionado ?? this.asesorSeleccionado,
      filtroAvanzado: filtroAvanzado ?? this.filtroAvanzado,
      cntSinValidar: cntSinValidar ?? this.cntSinValidar,
      cntValidados: cntValidados ?? this.cntValidados,
      conteosPorAsesor: conteosPorAsesor ?? this.conteosPorAsesor,
      recargandoLista: recargandoLista ?? this.recargandoLista,
      finLista: finLista ?? this.finLista,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      loadMoreError: limpiarLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
      cursorFecha: cursorFecha ?? this.cursorFecha,
      cursorNumsol: cursorNumsol ?? this.cursorNumsol,
    );
  }

  @override
  List<Object?> get props => [
    solicitudes,
    filtro,
    asesorSeleccionado,
    filtroAvanzado,
    cntSinValidar,
    cntValidados,
    recargandoLista,
    finLista,
    cargandoMas,
    loadMoreError,
    cursorFecha,
    cursorNumsol,
  ];
}
