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
  final Set<int> estadosSeleccionados;

  // Conteos por estado calculados sobre la lista filtrada por chip (sin filtro de estado)
  final Map<int, int> conteosPorEstado;

  // Asesor elegido en CobranzaAsesorPickerModal (chip "Asesores")
  final String? asesorSeleccionado;

  // Conteo de cobranzas por asesor (codUser) desglosado por idEstado,
  // calculado sobre _allCobranzas — alimenta CobranzaAsesorPickerModal, no
  // viene del backend
  final Map<String, Map<int, int>> conteosPorAsesor;

  // Pend. de documento (idEstado 0) sobre TODO lo cargado, sin filtro de
  // chip — alimenta el badge de Cobranza del drawer en tiempo real.
  final int pendientesDocumento;

  const CobranzaListSuccess({
    required this.cobranzas,
    required this.chipFiltro,
    required this.estadosSeleccionados,
    required this.conteosPorEstado,
    this.asesorSeleccionado,
    this.conteosPorAsesor = const {},
    this.pendientesDocumento = 0,
  });

  @override
  List<Object?> get props =>
      [cobranzas, chipFiltro, estadosSeleccionados, asesorSeleccionado];
}

class CobranzaListError extends CobranzaListState {
  final String message;
  const CobranzaListError(this.message);

  @override
  List<Object?> get props => [message];
}
