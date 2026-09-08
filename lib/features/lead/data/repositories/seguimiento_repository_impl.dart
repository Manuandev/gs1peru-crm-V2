// lib/features/lead/data/repositories/seguimiento_repository_impl.dart

import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoRepositoryImpl implements SeguimientoRepository {
  final SeguimientoRemoteDatasource _remote;

  const SeguimientoRepositoryImpl(this._remote);

  @override
  Future<SeguimientoPagina> traerPagina({
    LeadListFiltro filtro = LeadListFiltro.todos,
    String? cursorFecha,
    int? cursorIdContacto,
    required int tamanio,
  }) => _remote.traerPagina(
    filtro: filtro,
    cursorFecha: cursorFecha,
    cursorIdContacto: cursorIdContacto,
    tamanio: tamanio,
  );
}
