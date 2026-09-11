// lib/features/lead/domain/repositories/seguimiento_repository.dart
//
// Contrato de Seguimiento paginado (task 'LSP'). Separado de LeadRepository a
// propósito: implementación nueva, no toca la existente. Se provee local a la
// pantalla (no es global en app_widget.dart) — solo lo usa SeguimientoBloc.

import 'package:app_crm/features/lead/index_lead.dart';

abstract class SeguimientoRepository {
  Future<SeguimientoPagina> traerPagina({
    LeadListFiltro filtro,
    String? cursorFecha,
    int? cursorIdContacto,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
    String busqueda,
  });
}
