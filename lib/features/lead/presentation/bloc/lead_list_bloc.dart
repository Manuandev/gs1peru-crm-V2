// lib\features\lead\presentation\bloc\lead_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeadsUseCase;
  final _session = SessionService();

  List<Lead> _allLeads = [];
  late LeadListFiltro _filtroActivo;
  LeadType _currentType = LeadType.prospectos;
  // StreamSubscription<WebSocketMessage>? _messageSubscription;

  LeadListBloc(this._getLeadsUseCase) : super(const LeadListInitial()) {
    _filtroActivo = _session.isModerador
        ? LeadListFiltro.todos
        : LeadListFiltro.misCasos;
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
    on<LeadListFiltered>(_onFiltered);
  }

  Future<void> _onStarted(
    LeadListStarted event,
    Emitter<LeadListState> emit,
  ) async {
    emit(const LeadListLoading());
    await _loadData(event.type, emit);
  }

  Future<void> _onRefresh(
    LeadListRefresh event,
    Emitter<LeadListState> emit,
  ) async {
    emit(const LeadListLoading());
    await _loadData(event.type, emit);
  }

  Future<void> _loadData(LeadType type, Emitter<LeadListState> emit) async {
    _currentType = type;
    try {
      final leads = await _getLeadsUseCase(
        type == LeadType.prospectos ? 'PO' : 'PA',
      );
      _allLeads = leads;
      _emitFiltered(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(LeadListError(e.toString()));
    }
  }

  void _onFiltered(LeadListFiltered event, Emitter<LeadListState> emit) {
    _filtroActivo = event.filtro;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<LeadListState> emit) {
    final conteos = {
      LeadListFiltro.todos: _allLeads.length,
      LeadListFiltro.misCasos: _allLeads
          .where((c) => c.asignadoA == _session.codUser)
          .length,
      LeadListFiltro.nuevos: _allLeads.where((c) => c.idEstado == '00').length,
      LeadListFiltro.enDesarrollo: _allLeads
          .where((c) => c.idEstado == '01')
          .length,
    };

    var resultado = List<Lead>.from(_allLeads);
    if (_filtroActivo == LeadListFiltro.misCasos) {
      resultado = resultado
          .where((c) => c.asignadoA == _session.codUser)
          .toList();
    } else if (_filtroActivo == LeadListFiltro.nuevos) {
      resultado = resultado.where((c) => c.idEstado == '00').toList();
    } else if (_filtroActivo == LeadListFiltro.enDesarrollo) {
      resultado = resultado.where((c) => c.idEstado == '01').toList();
    }

    emit(
      LeadListSuccess(
        leads: resultado,
        filtro: _filtroActivo,
        conteos: conteos,
        type: _currentType,
      ),
    );
  }
}
