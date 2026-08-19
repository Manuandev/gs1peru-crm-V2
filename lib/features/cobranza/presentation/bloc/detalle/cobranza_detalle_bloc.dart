// lib/features/cobranza/presentation/bloc/detalle/cobranza_detalle_bloc.dart

import 'dart:async';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleBloc
    extends Bloc<CobranzaDetalleEvent, CobranzaDetalleState> {
  final GetDetalleCobranzaUseCase _getDetalleCobranzaUseCase;

  StreamSubscription<CobranzaUpdate>? _updateSub;
  String? _idCobranza;

  CobranzaDetalleBloc(this._getDetalleCobranzaUseCase)
      : super(const CobranzaDetalleInitial()) {
    on<CobranzaDetalleStarted>(_onStarted);
    on<CobranzaDetalleItemActualizado>(_onItemActualizado);

    _updateSub = CobranzaUpdateNotifier.instance.stream.listen((update) {
      if (!isClosed && update.numSol == _idCobranza) {
        add(
          CobranzaDetalleItemActualizado(
            update.idEstado,
            update.idCondicion,
            update.condicion,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
  }

  void _onItemActualizado(
    CobranzaDetalleItemActualizado event,
    Emitter<CobranzaDetalleState> emit,
  ) {
    final current = state;
    if (current is! CobranzaDetalleSuccess) return;

    final label = cobranzaEstadoLabel(event.idEstado);
    emit(
      CobranzaDetalleSuccess(
        current.detalle.copyWith(
          idEstado: event.idEstado,
          estado: label.isNotEmpty ? label : null,
          idCondicion: event.idCondicion,
          condicion: event.condicion,
        ),
      ),
    );
  }

  Future<void> _onStarted(
    CobranzaDetalleStarted event,
    Emitter<CobranzaDetalleState> emit,
  ) async {
    _idCobranza = event.idCobranza;
    emit(const CobranzaDetalleLoading());
    try {
      final detalle = await _getDetalleCobranzaUseCase(event.idCobranza);
      if (detalle == null) {
        emit(const CobranzaDetalleError('La cobranza no existe.'));
        return;
      }
      emit(CobranzaDetalleSuccess(detalle));
    } on AppException catch (e) {
      emit(CobranzaDetalleError(e.message));
    } catch (_) {
      emit(const CobranzaDetalleError('No se pudo cargar el detalle.'));
    }
  }
}
