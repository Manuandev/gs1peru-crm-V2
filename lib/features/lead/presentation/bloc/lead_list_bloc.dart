// lib\features\lead\presentation\bloc\lead_list_bloc.dart

import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeads;

  LeadListBloc(this._getLeads) : super(const LeadListInitial()) {
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
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
      final leadsF = _getLeads();

      final leads = await leadsF.catchError((_) => <LeadModel>[]);

      emit(LeadListLoaded(leads: leads));
    } catch (e, stackTrace) {
      addError(e, stackTrace);

      emit(LeadListError(e.toString()));
    }
  }
}
