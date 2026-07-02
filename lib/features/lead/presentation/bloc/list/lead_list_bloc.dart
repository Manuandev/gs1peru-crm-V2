// lib/features/lead/presentation/bloc/list/lead_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeadsUseCase;
  final ToggleFavoritoLeadUseCase _toggleFavoritoUseCase;

  List<Lead> _allLeads = [];
  late LeadListFiltro _filtroActivo;
  String? _asesorSeleccionado;
  StreamSubscription<LeadUpdate>? _updateSub;

  LeadListBloc(
    this._getLeadsUseCase,
    this._toggleFavoritoUseCase, {
    LeadListFiltro? filtroInicial,
  }) : super(const LeadListInitial()) {
    _filtroActivo = filtroInicial ?? LeadListFiltro.todos;
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
    on<LeadListFiltered>(_onFiltered);
    on<LeadListAsesorSeleccionado>(_onAsesorSeleccionado);
    on<ToggleFavoritoPressed>(_onToggleFavorito);
    on<LeadListLeadUpdated>(_onLeadUpdated);

    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final lead = update.updatedLead as Lead?;
      if (!isClosed && lead != null) add(LeadListLeadUpdated(lead));
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    LeadListStarted event,
    Emitter<LeadListState> emit,
  ) async {
    emit(const LeadListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    LeadListRefresh event,
    Emitter<LeadListState> emit,
  ) async {
    emit(const LeadListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<LeadListState> emit) async {
    try {
      final leads = await _getLeadsUseCase();
      _allLeads = leads;
      _emitFiltered(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(LeadListError(e.toString()));
    }
  }

  void _onFiltered(LeadListFiltered event, Emitter<LeadListState> emit) {
    _filtroActivo = event.filtro;
    if (event.filtro != LeadListFiltro.asesores) _asesorSeleccionado = null;
    _emitFiltered(emit);
  }

  void _onAsesorSeleccionado(
    LeadListAsesorSeleccionado event,
    Emitter<LeadListState> emit,
  ) {
    _filtroActivo = LeadListFiltro.asesores;
    _asesorSeleccionado = event.codUser;
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
      addError(e, stackTrace);
    }
  }

  void _onLeadUpdated(
    LeadListLeadUpdated event,
    Emitter<LeadListState> emit,
  ) {
    _allLeads = _allLeads
        .map((l) => l.idLead == event.lead.idLead ? event.lead : l)
        .toList();
    _emitFiltered(emit);
  }

  // Un lead pertenece a [idEstado] si coincide directo o si su idEstadoPadre
  // apunta a él — así un sub-estado (ej. "07 Solicita ficha", padre "01") se
  // cuenta dentro del padre "En desarrollo".
  bool _perteneceEstado(Lead lead, String idEstado) =>
      lead.idEstado == idEstado || lead.idEstadoPadre == idEstado;

  void _emitFiltered(Emitter<LeadListState> emit) {
    final conteos = {
      LeadListFiltro.todos: _allLeads.length,
      LeadListFiltro.nuevos:
          _allLeads.where((c) => _perteneceEstado(c, '00')).length,
      LeadListFiltro.enDesarrollo:
          _allLeads.where((c) => _perteneceEstado(c, '01')).length,
      LeadListFiltro.propuesta:
          _allLeads.where((c) => _perteneceEstado(c, '02')).length,
    };

    final conteosPorAsesor = <String, int>{};
    for (final lead in _allLeads) {
      conteosPorAsesor.update(
        lead.asesor,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }

    var resultado = List<Lead>.from(_allLeads);
    if (_filtroActivo == LeadListFiltro.asesores) {
      resultado = resultado
          .where((c) => c.asesor == _asesorSeleccionado)
          .toList();
    } else if (_filtroActivo == LeadListFiltro.nuevos) {
      resultado = resultado.where((c) => _perteneceEstado(c, '00')).toList();
    } else if (_filtroActivo == LeadListFiltro.enDesarrollo) {
      resultado = resultado.where((c) => _perteneceEstado(c, '01')).toList();
    } else if (_filtroActivo == LeadListFiltro.propuesta) {
      resultado = resultado.where((c) => _perteneceEstado(c, '02')).toList();
    }

    emit(
      LeadListSuccess(
        leads: resultado,
        filtro: _filtroActivo,
        conteos: conteos,
        asesorSeleccionado: _asesorSeleccionado,
        conteosPorAsesor: conteosPorAsesor,
      ),
    );
  }
}
