// lib/features/cobranza/presentation/bloc/lista/cobranza_list_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListBloc extends Bloc<CobranzaListEvent, CobranzaListState> {
  final GetCobranzasUseCase _getCobranzasUseCase;
  final _session = SessionService();

  List<Cobranza> _allCobranzas = [];
  CobranzaChipFiltro _chipFiltro = CobranzaChipFiltro.todos;

  // Set vacío = todos los estados activos (ninguna tarjeta filtrada)
  Set<String> _estadosSeleccionados = {};

  static const _todosLosEstados = {'F', 'PD', 'PP', 'CA'};

  CobranzaListBloc(this._getCobranzasUseCase) : super(const CobranzaListInitial()) {
    _chipFiltro = _session.isModerador
        ? CobranzaChipFiltro.todos
        : CobranzaChipFiltro.misCasos;
    on<CobranzaListStarted>(_onStarted);
    on<CobranzaListRefresh>(_onRefresh);
    on<CobranzaChipChanged>(_onChipChanged);
    on<CobranzaEstadoToggled>(_onEstadoToggled);
  }

  Future<void> _onStarted(
    CobranzaListStarted event,
    Emitter<CobranzaListState> emit,
  ) async {
    emit(const CobranzaListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    CobranzaListRefresh event,
    Emitter<CobranzaListState> emit,
  ) async {
    emit(const CobranzaListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<CobranzaListState> emit) async {
    try {
      _allCobranzas = await _getCobranzasUseCase();
      _emitFiltered(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(CobranzaListError(e.toString()));
    }
  }

  void _onChipChanged(CobranzaChipChanged event, Emitter<CobranzaListState> emit) {
    _chipFiltro = event.filtro;
    _emitFiltered(emit);
  }

  void _onEstadoToggled(CobranzaEstadoToggled event, Emitter<CobranzaListState> emit) {
    final id = event.idEstado;
    final actuales = Set<String>.from(
      _estadosSeleccionados.isEmpty ? _todosLosEstados : _estadosSeleccionados,
    );

    if (actuales.contains(id)) {
      // No permitir deseleccionar el último estado activo
      if (actuales.length == 1) return;
      actuales.remove(id);
    } else {
      actuales.add(id);
    }

    // Si están todos activos, volvemos a set vacío (= sin filtro de estado)
    _estadosSeleccionados =
        actuales.length == _todosLosEstados.length ? {} : actuales;

    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<CobranzaListState> emit) {
    // 1. Aplicar filtro de chip
    var porChip = List<Cobranza>.from(_allCobranzas);
    if (_chipFiltro == CobranzaChipFiltro.misCasos) {
      porChip = porChip.where((c) => c.asignadoA == _session.codUser).toList();
    } else if (_chipFiltro == CobranzaChipFiltro.contado) {
      porChip = porChip.where((c) => c.idCondicion == 'C').toList();
    } else if (_chipFiltro == CobranzaChipFiltro.credito) {
      porChip = porChip.where((c) => c.idCondicion == 'CR').toList();
    }

    // 2. Conteos por estado sobre lista ya filtrada por chip (antes del filtro de tarjetas)
    final conteos = <String, int>{
      'F': porChip.where((c) => c.idEstado == 'F').length,
      'PD': porChip.where((c) => c.idEstado == 'PD').length,
      'PP': porChip.where((c) => c.idEstado == 'PP').length,
      'CA': porChip.where((c) => c.idEstado == 'CA').length,
    };

    // 3. Aplicar filtro de estados (tarjetas)
    var resultado = porChip;
    if (_estadosSeleccionados.isNotEmpty) {
      resultado = porChip.where((c) => _estadosSeleccionados.contains(c.idEstado)).toList();
    }

    emit(
      CobranzaListSuccess(
        cobranzas: resultado,
        chipFiltro: _chipFiltro,
        estadosSeleccionados: Set.from(_estadosSeleccionados),
        conteosPorEstado: conteos,
      ),
    );
  }
}
