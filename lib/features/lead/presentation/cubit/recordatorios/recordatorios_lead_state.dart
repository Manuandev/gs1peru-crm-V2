// lib/features/lead/presentation/cubit/recordatorios/recordatorios_lead_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

sealed class RecordatoriosLeadState extends Equatable {
  const RecordatoriosLeadState();

  @override
  List<Object?> get props => [];
}

class RecordatoriosLeadInitial extends RecordatoriosLeadState {
  const RecordatoriosLeadInitial();
}

class RecordatoriosLeadLoading extends RecordatoriosLeadState {
  const RecordatoriosLeadLoading();
}

class RecordatoriosLeadSuccess extends RecordatoriosLeadState {
  final List<LeadRecordatorio> recordatorios;

  const RecordatoriosLeadSuccess({required this.recordatorios});

  @override
  List<Object?> get props => [recordatorios];
}

class RecordatoriosLeadError extends RecordatoriosLeadState {
  final String mensaje;

  const RecordatoriosLeadError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
