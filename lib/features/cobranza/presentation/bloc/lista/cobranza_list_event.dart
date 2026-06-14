// lib/features/cobranza/presentation/bloc/lista/cobranza_list_event.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaListEvent extends Equatable {
  const CobranzaListEvent();

  @override
  List<Object?> get props => [];
}

class CobranzaListStarted extends CobranzaListEvent {
  const CobranzaListStarted();
}

class CobranzaListRefresh extends CobranzaListEvent {
  const CobranzaListRefresh();
}

// Cambia el chip activo (Todos / Mis casos / Contado / Crédito)
class CobranzaChipChanged extends CobranzaListEvent {
  final CobranzaChipFiltro filtro;
  const CobranzaChipChanged(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

// Activa o desactiva una tarjeta de estado (multi-selección)
class CobranzaEstadoToggled extends CobranzaListEvent {
  final String idEstado;
  const CobranzaEstadoToggled(this.idEstado);

  @override
  List<Object?> get props => [idEstado];
}
