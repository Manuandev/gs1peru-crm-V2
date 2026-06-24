// lib/features/solicitudes/presentation/bloc/list/solicitud_list_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListBloc extends Bloc<SolicitudListEvent, SolicitudListState> {
  final GetSolicitudesUseCase _getSolicitudesUseCase;
  final _session = SessionService();

  List<Solicitud> _allSolicitudes = [];
  SolicitudFiltro _filtroActivo = SolicitudFiltro.todas;

  SolicitudListBloc(this._getSolicitudesUseCase)
      : super(const SolicitudListInitial()) {
    on<SolicitudListStarted>(_onStarted);
    on<SolicitudListRefresh>(_onRefresh);
    on<SolicitudListFiltered>(_onFiltered);
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
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<SolicitudListState> emit) {
    final resultado = switch (_filtroActivo) {
      SolicitudFiltro.todas => List<Solicitud>.from(_allSolicitudes),
      SolicitudFiltro.asesores => _allSolicitudes
          .where((s) => s.asesor == _session.codUser)
          .toList(),
      SolicitudFiltro.sinValidar => _allSolicitudes
          .where((s) => s.idEstado == '01')
          .toList(),
      SolicitudFiltro.enviarACobranza => _allSolicitudes
          .where((s) => s.idEstado == '03')
          .toList(),
    };

    emit(SolicitudListSuccess(
      solicitudes: resultado,
      filtro: _filtroActivo,
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
}
