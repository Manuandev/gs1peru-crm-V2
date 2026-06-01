// lib/core/presentation/bloc/catalog/catalog_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

class CatalogsBloc extends Bloc<CatalogsEvent, CatalogsState> {
  final GetCatalogsUseCase _getData; 

  CatalogsBloc({required GetCatalogsUseCase getData})
    : _getData = getData,
      super(const CatalogsInitial()) {
    on<CatalogsLoadRequested>(_onLoad);
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
}
