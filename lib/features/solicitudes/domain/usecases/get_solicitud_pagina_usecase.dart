// lib/features/solicitudes/domain/usecases/get_solicitud_pagina_usecase.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud_pagina.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class GetSolicitudPaginaUseCase {
  final SolicitudRepository _repository;
  const GetSolicitudPaginaUseCase(this._repository);

  Future<SolicitudPagina> call({
    String chip = '',
    String? idAsesor,
    String? cursorFecha,
    String? cursorNumsol,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
  }) => _repository.traerPagina(
    chip: chip,
    idAsesor: idAsesor,
    cursorFecha: cursorFecha,
    cursorNumsol: cursorNumsol,
    tamanio: tamanio,
    fcDesde: fcDesde,
    fcHasta: fcHasta,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
  );
}
