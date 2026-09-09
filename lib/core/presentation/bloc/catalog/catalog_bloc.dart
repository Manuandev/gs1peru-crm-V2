// lib/core/presentation/bloc/catalog/catalog_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

class CatalogsBloc extends Bloc<CatalogsEvent, CatalogsState> {
  final GetCatalogsUseCase _getData;
  final GetCatalogosEditarNegociacionUseCase _getEditarNegociacion;
  final GetCatalogosFiltrosUseCase _getFiltros;

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
  }

  Future<void> _onLoad(
    CatalogsLoadRequested event,
    Emitter<CatalogsState> emit,
  ) async {
    try {
      final listas = await _getData.call();

      emit(CatalogsLoaded(listas: listas));
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
        ),
      );
    } catch (_) {}
  }
}
