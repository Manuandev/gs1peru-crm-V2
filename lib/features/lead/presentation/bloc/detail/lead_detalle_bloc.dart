// lib/features/lead/presentation/bloc/detail/lead_detalle_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleBloc extends Bloc<LeadDetalleEvent, LeadDetalleState> {
  final GetLeadDetalleUseCase _getData;

  LeadDetalleBloc(this._getData) : super(const LeadDetalleInitial()) {
    on<LeadDetalleStarted>(_onStarted);
    on<LeadDetalleRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    LeadDetalleStarted event,
    Emitter<LeadDetalleState> emit,
  ) async {
    emit(const LeadDetalleLoading());
    await _loadData(event.idLead, emit);
  }

  Future<void> _onRefresh(
    LeadDetalleRefresh event,
    Emitter<LeadDetalleState> emit,
  ) async {
    emit(const LeadDetalleLoading());
    await _loadData(event.idLead, emit);
  }

  Future<void> _loadData(int idLead, Emitter<LeadDetalleState> emit) async {
    try {
      final leadDetalle = await _getData.call(idLead);

      emit(LeadDetalleLoaded(detalle: leadDetalle));
    } on AppException catch (e) {
      emit(LeadDetalleError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(LeadDetalleError(e.toString()));
    }
  }
}
