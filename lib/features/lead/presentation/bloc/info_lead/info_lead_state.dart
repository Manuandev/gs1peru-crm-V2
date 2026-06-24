// lib/features/lead/presentation/bloc/info_lead/info_lead_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

sealed class InfoLeadState extends Equatable {
  const InfoLeadState();

  @override
  List<Object?> get props => [];
}

class InfoLeadInitial extends InfoLeadState {
  const InfoLeadInitial();
}

class InfoLeadLoading extends InfoLeadState {
  const InfoLeadLoading();
}

class InfoLeadSuccess extends InfoLeadState {
  final Lead lead;
  // Flags de conversación WhatsApp — pertenecen al número, no al lead.
  // Se almacenan aquí para que ChatInputBar pueda leerlos sin que Lead los cargue.
  final bool isBloqueado;
  final bool isExpirado;
  final bool isCerrado;

  const InfoLeadSuccess(
    this.lead, {
    this.isBloqueado = false,
    this.isExpirado = false,
    this.isCerrado = false,
  });

  @override
  List<Object?> get props => [lead, isBloqueado, isExpirado, isCerrado];
}

class InfoLeadFailure extends InfoLeadState {
  final String message;
  const InfoLeadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
