// lib/features/cobranza/presentation/bloc/lista/cobranza_list_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaListState extends Equatable {
  const CobranzaListState();

  @override
  List<Object?> get props => [];
}

class CobranzaListInitial extends CobranzaListState {
  const CobranzaListInitial();
}

class CobranzaListLoading extends CobranzaListState {
  const CobranzaListLoading();
}

class CobranzaListSuccess extends CobranzaListState {
  final List<Cobranza> cobranzas;
  final CobranzaChipFiltro chipFiltro;

  // Set vacío = todos los estados visibles
  final Set<String> estadosSeleccionados;

  // Conteos por estado calculados sobre la lista filtrada por chip (sin filtro de estado)
  final Map<String, int> conteosPorEstado;

  const CobranzaListSuccess({
    required this.cobranzas,
    required this.chipFiltro,
    required this.estadosSeleccionados,
    required this.conteosPorEstado,
  });

  @override
  List<Object?> get props => [cobranzas, chipFiltro, estadosSeleccionados];
}

class CobranzaListError extends CobranzaListState {
  final String message;
  const CobranzaListError(this.message);

  @override
  List<Object?> get props => [message];
}
