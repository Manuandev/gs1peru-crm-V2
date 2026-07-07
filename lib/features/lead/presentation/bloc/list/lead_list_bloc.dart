// lib/features/lead/presentation/bloc/list/lead_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeadsUseCase;

  List<ContactoNegociacion> _allLeads = [];
  late LeadListFiltro _filtroActivo;
  StreamSubscription<LeadUpdate>? _updateSub;

  LeadListBloc(
    this._getLeadsUseCase, {
    LeadListFiltro? filtroInicial,
  }) : super(const LeadListInitial()) {
    _filtroActivo = filtroInicial ?? LeadListFiltro.todos;
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
    on<LeadListFiltered>(_onFiltered);
    on<LeadListLeadUpdated>(_onLeadUpdated);

    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      final negociacion = update.updatedLead as Negociacion?;
      if (!isClosed && negociacion != null) {
        add(LeadListLeadUpdated(negociacion));
      }
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
    _emitFiltered(emit);
  }

  void _onLeadUpdated(
    LeadListLeadUpdated event,
    Emitter<LeadListState> emit,
  ) {
    _allLeads = _allLeads
        .map(
          (c) => c.negociacion.idLead == event.negociacion.idLead
              ? c.copyWith(negociacion: event.negociacion)
              : c,
        )
        .toList();
    _emitFiltered(emit);
  }

  // Un lead pertenece a [idEstado] si coincide directo o si su idEstadoPadre
  // apunta a él — así un sub-estado (ej. "07 Solicita ficha", padre "01") se
  // cuenta dentro del padre "En desarrollo".
  bool _perteneceEstado(ContactoNegociacion item, String idEstado) =>
      item.negociacion.idEstado == idEstado ||
      item.negociacion.idEstadoPadre == idEstado;

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

    var resultado = List<ContactoNegociacion>.from(_allLeads);
    if (_filtroActivo == LeadListFiltro.nuevos) {
      resultado = resultado.where((c) => _perteneceEstado(c, '00')).toList();
    } else if (_filtroActivo == LeadListFiltro.enDesarrollo) {
      resultado = resultado.where((c) => _perteneceEstado(c, '01')).toList();
    } else if (_filtroActivo == LeadListFiltro.propuesta) {
      resultado = resultado.where((c) => _perteneceEstado(c, '02')).toList();
    }

    emit(
      LeadListSuccess(
        contactos: resultado,
        filtro: _filtroActivo,
        conteos: conteos,
      ),
    );
  }
}
