// lib/core/presentation/bloc/filtro/filtro_cubit.dart

import 'package:app_crm/index_dependencies.dart';

import 'filtro_state.dart';

class FiltroCubit extends Cubit<FiltroState> {
  FiltroCubit() : super(const FiltroState());

  void cambiarVista(FiltroVista nueva) {
    if (state.vista == nueva) return;
    emit(FiltroState(vista: nueva));
  }
}
