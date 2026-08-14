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
      SolicitudFiltro.asesores =>
        _allSolicitudes.where((s) => s.asesor == _asesorSeleccionado).toList(),
      SolicitudFiltro.sinValidar =>
        _allSolicitudes.where((s) => !s.ibValidado).toList(),
      SolicitudFiltro.enviarACobranza =>
        _allSolicitudes.where((s) => s.ibValidado).toList(),
    };

    final q = _lastSearchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      resultado = resultado
          .where(
            (s) =>
                s.nombre.toLowerCase().contains(q) ||
                s.apellidos.toLowerCase().contains(q) ||
                s.nombreEmpresa.toLowerCase().contains(q) ||
                s.telefono.contains(q) ||
                s.idSolicitud.toLowerCase().contains(q),
          )
          .toList();
    }

    emit(
      SolicitudListSuccess(
        solicitudes: resultado,
        filtro: _filtroActivo,
        asesorSeleccionado: _asesorSeleccionado,
        conteosPorAsesor: _buildConteosPorAsesor(),
        cntSinValidar: _allSolicitudes.where((s) => !s.ibValidado).length,
        cntValidados: _allSolicitudes.where((s) => s.ibValidado).length,
      ),
    );
  }

  // Conteo de solicitudes por asesor (codUser), desglosado por
  // ibValidado (false=sin validar, true=validado), sobre el total cargado —
  // alimenta SolicitudAsesorPickerModal, no viene del backend. Antes era un
  // total plano (Map<String,int>) — el usuario pidió ver también en qué
  // estado está cada solicitud de ese asesor, no solo cuántas tiene.
  Map<String, Map<bool, int>> _buildConteosPorAsesor() {
    final conteos = <String, Map<bool, int>>{};
    for (final s in _allSolicitudes) {
      if (s.asesor.isEmpty) continue;
      final porValidado = conteos.putIfAbsent(s.asesor, () => {});
      porValidado[s.ibValidado] = (porValidado[s.ibValidado] ?? 0) + 1;
    }
    return conteos;
  }
}
