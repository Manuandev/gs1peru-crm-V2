// lib/features/cobranza/domain/usecases/get_cobranza_pagina_usecase.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GetCobranzaPaginaUseCase {
  final CobranzaRepository _repository;
  const GetCobranzaPaginaUseCase(this._repository);

  Future<CobranzaPagina> call({
    CobranzaChipFiltro chip = CobranzaChipFiltro.todos,
    String? codAsesor,
    String? cursorFecha,
    String? cursorNumSol,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
    Set<int> estados = const {},
  }) => _repository.traerPagina(
    chip: chip,
    codAsesor: codAsesor,
    cursorFecha: cursorFecha,
    cursorNumSol: cursorNumSol,
    tamanio: tamanio,
    fcDesde: fcDesde,
    fcHasta: fcHasta,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
    estados: estados,
  );
}
