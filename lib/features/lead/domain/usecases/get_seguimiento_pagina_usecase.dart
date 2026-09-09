// lib/features/lead/domain/usecases/get_seguimiento_pagina_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetSeguimientoPaginaUseCase {
  final SeguimientoRepository _repository;
  const GetSeguimientoPaginaUseCase(this._repository);

  Future<SeguimientoPagina> call({
    LeadListFiltro filtro = LeadListFiltro.todos,
    String? cursorFecha,
    int? cursorIdContacto,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
  }) => _repository.traerPagina(
    filtro: filtro,
    cursorFecha: cursorFecha,
    cursorIdContacto: cursorIdContacto,
    tamanio: tamanio,
    fcDesde: fcDesde,
    fcHasta: fcHasta,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
  );
}
