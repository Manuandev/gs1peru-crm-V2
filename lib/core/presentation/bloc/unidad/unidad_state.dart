// lib/core/presentation/bloc/unidad/unidad_state.dart

import 'package:app_crm/index_dependencies.dart';

class UnidadState extends Equatable {
  /// Unidades asignadas al asesor, en el orden del login (la primera es la
  /// asignación más reciente).
  final List<int> unidades;

  /// Unidad con la que se filtran listas, contadores y combos. `null` si el
  /// asesor no tiene unidades asignadas.
  final int? idUnidadActiva;

  const UnidadState({this.unidades = const [], this.idUnidadActiva});

  bool get tieneUnidades => unidades.isNotEmpty;

  /// El selector del drawer solo se habilita con más de una unidad.
  bool get puedeCambiar => unidades.length > 1;

  @override
  List<Object?> get props => [unidades, idUnidadActiva];
}
