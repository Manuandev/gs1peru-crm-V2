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

// Cambia el chip activo (Todos / Asesores / Contado / Crédito)
class CobranzaChipChanged extends CobranzaListEvent {
  final CobranzaChipFiltro filtro;
  const CobranzaChipChanged(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

// Asesor elegido en CobranzaAsesorPickerModal (chip "Asesores")
class CobranzaAsesorSeleccionado extends CobranzaListEvent {
  final String codAsesor;
  const CobranzaAsesorSeleccionado(this.codAsesor);

  @override
  List<Object?> get props => [codAsesor];
}

// Activa o desactiva una tarjeta de estado (multi-selección)
class CobranzaEstadoToggled extends CobranzaListEvent {
  final int idEstado;
  const CobranzaEstadoToggled(this.idEstado);

  @override
  List<Object?> get props => [idEstado];
}

// Llega desde CobranzaUpdateNotifier tras facturar — parchea el idEstado
// de esa cobranza en memoria sin recargar toda la lista del backend.
class CobranzaListItemActualizado extends CobranzaListEvent {
  final String numSol;
  final int idEstado;
  const CobranzaListItemActualizado(this.numSol, this.idEstado);

  @override
  List<Object?> get props => [numSol, idEstado];
}
