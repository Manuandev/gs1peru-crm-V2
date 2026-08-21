// lib/core/network/catalog_remote_datasource.dart

// catalog_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

class CatalogsRemoteDatasource {
  final ApiClient _api = ApiClient();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Future<ListasGenericasModel> getListas() async {
    final String body = '${sep}L';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ListasGenericasModel.parse(data),
      ApiEmpty() => ListasGenericasModel(
        campanias: [],
        oportunidades: [],
        canales: [],
        intereses: [],
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'TC' — SOLO tipo de cambio del día (venta/compra), sin traer el
  // catálogo completo. Usado al validar el plan de crédito en cobranza/
  // (mismo endpoint urlListasLst, cuerpo distinto) — ver cobranza/CLAUDE.md.
  Future<TipoCambioItem> getTipoCambio() async {
    final String body = '${sep}TC';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => data.trim().isEmpty
          ? const TipoCambioItem()
          : TipoCambioItemModel.fromRawString(data),
      ApiEmpty() => const TipoCambioItem(),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'ASE' — SOLO el universo de asesores (mismo dataset que la parte [5]
  // del catálogo completo), sin traer el resto. Usado para refrescar el
  // picker de Asesores (cobranza/solicitudes) sin recargar todo el catálogo.
  Future<List<AsesorItem>> getAsesores() async {
    final String body = '${sep}ASE';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => data.trim().isEmpty
          ? const <AsesorItem>[]
          : AsesorItemModel.parseList(data),
      ApiEmpty() => const <AsesorItem>[],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'EN' — SOLO estados/campañas/oportunidades/canales/intereses/monedas,
  // sin traer el catálogo completo. Usado al entrar a "Editar negociación"
  // (lead/EditLeadPortrait) para refrescar esos catálogos, ver lead/CLAUDE.md.
  Future<
    ({
      List<EstadoItem> estados,
      List<CampaniaItem> campanias,
      List<OportunidadItem> oportunidades,
      List<CanalItem> canales,
      List<InteresItem> intereses,
      List<MonedaItem> monedas,
    })
  >
  getCatalogosEditarNegociacion() async {
    final String body = '${sep}EN';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    const vacio = (
      estados: <EstadoItem>[],
      campanias: <CampaniaItem>[],
      oportunidades: <OportunidadItem>[],
      canales: <CanalItem>[],
      intereses: <InteresItem>[],
      monedas: <MonedaItem>[],
    );

    return switch (result) {
      ApiSuccess(:final data) => data.trim().isEmpty
          ? vacio
          : ListasGenericasModel.parseEditarNegociacion(data),
      ApiEmpty() => vacio,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
