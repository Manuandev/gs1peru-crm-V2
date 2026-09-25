// lib/core/presentation/bloc/catalog/catalog_bloc.dart

import 'dart:async';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

class CatalogsBloc extends Bloc<CatalogsEvent, CatalogsState> {
  final GetCatalogsUseCase _getData;
  final GetCatalogosEditarNegociacionUseCase _getEditarNegociacion;
  final GetCatalogosFiltrosUseCase _getFiltros;

  // Los combos se filtran por la unidad activa — al cambiarla en el drawer se
  // re-emite el estado con la nueva unidad (sin llamar al backend).
  late final StreamSubscription<UnidadState> _unidadSub;

  CatalogsBloc({
    required GetCatalogsUseCase getData,
    required GetCatalogosEditarNegociacionUseCase getEditarNegociacion,
    required GetCatalogosFiltrosUseCase getFiltros,
  }) : _getData = getData,
       _getEditarNegociacion = getEditarNegociacion,
       _getFiltros = getFiltros,
       super(const CatalogsInitial()) {
    on<CatalogsLoadRequested>(_onLoad);
    on<CatalogsNegociacionRefreshed>(_onNegociacionRefresh);
    on<CatalogsFiltrosRefreshed>(_onFiltrosRefresh);
    on<CatalogsUnidadCambiada>(_onUnidadCambiada);

    _unidadSub = UnidadCubit.instance.stream.listen(
      (unidad) => add(CatalogsUnidadCambiada(unidad.idUnidadActiva)),
    );
  }

  int? get _idUnidadActiva => UnidadCubit.instance.state.idUnidadActiva;

  @override
  Future<void> close() {
    _unidadSub.cancel();
    return super.close();
  }

  void _onUnidadCambiada(
    CatalogsUnidadCambiada event,
    Emitter<CatalogsState> emit,
  ) {
    final current = state;
    if (current is! CatalogsLoaded) return;
    emit(CatalogsLoaded(listas: current.listas, idUnidad: event.idUnidad));
  }

  Future<void> _onLoad(
    CatalogsLoadRequested event,
    Emitter<CatalogsState> emit,
  ) async {
    try {
      final listas = await _getData.call();

      emit(CatalogsLoaded(listas: listas, idUnidad: _idUnidadActiva));
    } on AppException catch (e) {
      emit(CatalogsError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(CatalogsError(e.toString()));
    }
  }

  // Falla silenciosa a propósito — es un refresh de fondo al entrar a
  // "Editar negociación", no debe mostrar ningún error si no hay conexión;
  // la pantalla simplemente se queda con el catálogo que ya tenía.
  Future<void> _onNegociacionRefresh(
    CatalogsNegociacionRefreshed event,
    Emitter<CatalogsState> emit,
  ) async {
    final current = state;
    if (current is! CatalogsLoaded) return;

    try {
      final datos = await _getEditarNegociacion.call();
      emit(
        CatalogsLoaded(
          listas: current.listas.copyWith(
            estados: datos.estados,
            campanias: datos.campanias,
            oportunidades: datos.oportunidades,
            canales: datos.canales,
            intereses: datos.intereses,
            monedas: datos.monedas,
          ),
          idUnidad: current.idUnidad,
        ),
      );
    } catch (_) {}
  }

  // Refresco de fondo de campañas + oportunidades + eventos al entrar a
  // Conversaciones/Seguimiento/Solicitudes. Falla en silencio, igual que el
  // refresh de "Editar negociación".
  Future<void> _onFiltrosRefresh(
    CatalogsFiltrosRefreshed event,
    Emitter<CatalogsState> emit,
  ) async {
    final current = state;
    if (current is! CatalogsLoaded) return;

    try {
      final datos = await _getFiltros.call();
      emit(
        CatalogsLoaded(
          listas: current.listas.copyWith(
            campanias: datos.campanias,
            oportunidades: datos.oportunidades,
            eventos: datos.eventos,
          ),
          idUnidad: current.idUnidad,
        ),
      );
    } catch (_) {}
  }
}
