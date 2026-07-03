// lib/features/solicitudes/presentation/bloc/list/solicitud_list_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListBloc extends Bloc<SolicitudListEvent, SolicitudListState> {
  final GetSolicitudesUseCase _getSolicitudesUseCase;

  List<Solicitud> _allSolicitudes = [];
  SolicitudFiltro _filtroActivo = SolicitudFiltro.todas;
  String _lastSearchQuery = '';
  String? _asesorSeleccionado;

  SolicitudListBloc(this._getSolicitudesUseCase)
      : super(const SolicitudListInitial()) {
    on<SolicitudListStarted>(_onStarted);
    on<SolicitudListRefresh>(_onRefresh);
    on<SolicitudListFiltered>(_onFiltered);
    on<SolicitudListSearched>(_onSearched);
    on<SolicitudListAsesorSeleccionado>(_onAsesorSeleccionado);
  }

  Future<void> _onStarted(
    SolicitudListStarted event,
    Emitter<SolicitudListState> emit,
  ) async {
    emit(const SolicitudListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    SolicitudListRefresh event,
    Emitter<SolicitudListState> emit,
  ) async {
    emit(const SolicitudListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<SolicitudListState> emit) async {
    try {
      final solicitudes = await _getSolicitudesUseCase();
      _allSolicitudes = solicitudes;
      _emitFiltered(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(SolicitudListError(e.toString()));
    }
  }

  void _onFiltered(
    SolicitudListFiltered event,
    Emitter<SolicitudListState> emit,
  ) {
    _filtroActivo = event.filtro;
    if (_filtroActivo != SolicitudFiltro.asesores) _asesorSeleccionado = null;
    _emitFiltered(emit);
  }

  void _onAsesorSeleccionado(
    SolicitudListAsesorSeleccionado event,
    Emitter<SolicitudListState> emit,
  ) {
    _asesorSeleccionado = event.codAsesor;
    _filtroActivo = SolicitudFiltro.asesores;
    _emitFiltered(emit);
  }

  void _onSearched(
    SolicitudListSearched event,
    Emitter<SolicitudListState> emit,
  ) {
    _lastSearchQuery = event.query;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<SolicitudListState> emit) {
    var resultado = switch (_filtroActivo) {
      SolicitudFiltro.todas => List<Solicitud>.from(_allSolicitudes),
      SolicitudFiltro.asesores => _allSolicitudes
          .where((s) => s.asesor == _asesorSeleccionado)
          .toList(),
      SolicitudFiltro.sinValidar => _allSolicitudes
          .where((s) => s.idEstado == '01')
          .toList(),
      SolicitudFiltro.enviarACobranza => _allSolicitudes
          .where((s) => s.idEstado == '03')
          .toList(),
    };

    final q = _lastSearchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      resultado = resultado
          .where(
            (s) =>
                s.nombre.toLowerCase().contains(q) ||
                s.apellido.toLowerCase().contains(q) ||
                s.nombreEmpresa.toLowerCase().contains(q) ||
                s.telefono.contains(q) ||
                s.idSolicitud.toString().contains(q),
          )
          .toList();
    }

    emit(SolicitudListSuccess(
      solicitudes: resultado,
      filtro: _filtroActivo,
      asesorSeleccionado: _asesorSeleccionado,
      asesoresDisponibles: _buildAsesoresDisponibles(),
      cntPorCompletar:
          _allSolicitudes.where((s) => s.idEstado == '00').length,
      cntPorValidar:
          _allSolicitudes.where((s) => s.idEstado == '01').length,
      cntConDocumentos:
          _allSolicitudes.where((s) => s.idEstado == '02').length,
      cntListasCobranza:
          _allSolicitudes.where((s) => s.idEstado == '03').length,
    ));
  }

  // Asesores distintos entre todas las solicitudes — para el modal
  // del chip "Asesores" (SolicitudAsesorPickerModal)
  List<AsesorResumen> _buildAsesoresDisponibles() {
    final agrupado = <String, AsesorResumen>{};
    for (final s in _allSolicitudes) {
      if (s.asesor.isEmpty) continue;
      final actual = agrupado[s.asesor];
      agrupado[s.asesor] = AsesorResumen(
        cod: s.asesor,
        nombre: s.nombreAsesor,
        cantidad: (actual?.cantidad ?? 0) + 1,
      );
    }
    final lista = agrupado.values.toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
    return lista;
  }
}
