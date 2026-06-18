// lib/features/lead/presentation/bloc/list/lead_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeadsUseCase;
  final ToggleFavoritoLeadUseCase _toggleFavoritoUseCase;
  final _session = SessionService();

  List<Lead> _allLeads = [];
  late LeadListFiltro _filtroActivo;
  LeadType _currentType = LeadType.seguimientos;
  // StreamSubscription<WebSocketMessage>? _messageSubscription;

  LeadListBloc(this._getLeadsUseCase, this._toggleFavoritoUseCase)
      : super(const LeadListInitial()) {
    _filtroActivo = _session.isModerador
        ? LeadListFiltro.todos
        : LeadListFiltro.misCasos;
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
    on<LeadListFiltered>(_onFiltered);
    on<ToggleFavoritoPressed>(_onToggleFavorito);
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

    if (_currentType == LeadType.propuestas &&
        (_filtroActivo == LeadListFiltro.nuevos ||
            _filtroActivo == LeadListFiltro.enDesarrollo)) {
      _filtroActivo = LeadListFiltro.misCasos;
    }

    try {
      final leads = await _getLeadsUseCase(
        type == LeadType.seguimientos ? 'PO' : 'PA',
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

  Future<void> _onToggleFavorito(
    ToggleFavoritoPressed event,
    Emitter<LeadListState> emit,
  ) async {
    // Actualización optimista: cambia el ícono de inmediato
    _allLeads = _allLeads
        .map((l) => l.idLead == event.idLead
            ? l.copyWith(isFavorito: event.nuevoValor)
            : l)
        .toList();
    _emitFiltered(emit);

    try {
      await _toggleFavoritoUseCase(event.idLead, event.nuevoValor);
    } catch (e, stackTrace) {
      // Revertir si falla
      _allLeads = _allLeads
          .map((l) => l.idLead == event.idLead
              ? l.copyWith(isFavorito: !event.nuevoValor)
              : l)
          .toList();
      _emitFiltered(emit);
      // TODO: mostrar AppSnackBar.error cuando se conecte al SP real
      addError(e, stackTrace);
    }
  }

  void _emitFiltered(Emitter<LeadListState> emit) {
    final conteos = {
      LeadListFiltro.todos: _allLeads.length,
      LeadListFiltro.misCasos: _allLeads
          .where((c) => c.asesor == _session.codUser)
          .length,
      LeadListFiltro.nuevos: _allLeads.where((c) => c.idEstado == '00').length,
      LeadListFiltro.enDesarrollo: _allLeads
          .where((c) => c.idEstado == '01')
          .length,
    };

    var resultado = List<Lead>.from(_allLeads);
    if (_filtroActivo == LeadListFiltro.misCasos) {
      resultado = resultado
          .where((c) => c.asesor == _session.codUser)
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
