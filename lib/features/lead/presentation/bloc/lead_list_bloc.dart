// lib\features\lead\presentation\bloc\lead_list_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/lead/index_lead.dart';

class LeadListBloc extends Bloc<LeadListEvent, LeadListState> {
  final GetLeadsUseCase _getLeadsUseCase;

  LeadListBloc(this._getLeadsUseCase) : super(const LeadListInitial()) {
    on<LeadListStarted>(_onStarted);
    on<LeadListRefresh>(_onRefresh);
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
    try {
      final List<Lead> leads = await _getLeadsUseCase(
        type == LeadType.prospectos ? 'PO' : 'PA',
      );

      emit(LeadListLoaded(leads: leads, type: type));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(LeadListError(e.toString()));
    }
  }
}
