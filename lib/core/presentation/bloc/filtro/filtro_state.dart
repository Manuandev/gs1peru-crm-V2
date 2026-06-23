// lib/core/presentation/bloc/filtro/filtro_state.dart

import 'package:app_crm/index_dependencies.dart';

enum FiltroVista { miEquipo, misCasos }

class FiltroState extends Equatable {
  final FiltroVista vista;

  const FiltroState({this.vista = FiltroVista.miEquipo});

  @override
  List<Object> get props => [vista];
}
