// lib/features/cobranza/data/datasources/remote/cobranza_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  // Tamaños de página del task 'LSP' (el SP los acota a 1..100).
  static const int tamanioPrimera = 40;
  static const int tamanioSiguiente = 20;

  Future<List<CobranzaModel>> getCobranzas() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';

    final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => CobranzaModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'LSP' — lista paginada (keyset). Body:
  //   codUser¦mod¦chip¦idAsesor¦curFecha¦curNumsol¦tam¦fcDesde¦fcHasta¦
  //   idCampania¦idOportunidad¦estados
  //   chip     '' = todos ; 'C' = contado ; 'CR' = crédito
  //   idAsesor '' = no aplica (solo lo manda el chip "Asesores")
  //   cur*     '' = primera página
  //   fc*      ISO 126 ('yyyy-MM-ddTHH:mm:ss'), '' = no aplica
  //   estados  ID_ESTADO_GES separados por coma (ej. '2,5'), '' = los 4
  Future<CobranzaPagina> traerPagina({
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
  }) async {
    final camp = AppConstants.sepCampos;
    final sep = AppConstants.sepListas;

    final data = [
      _session.codUser,
      _session.isModerador ? 1 : 0,
      _codigoChip(chip),
      chip == CobranzaChipFiltro.asesores ? (codAsesor ?? '') : '',
      cursorFecha ?? '',
      cursorNumSol ?? '',
      tamanio,
      _fmtFecha(fcDesde),
      _fmtFecha(fcHasta),
      idCampania ?? '',
      idOportunidad ?? '',
      (estados.toList()..sort()).join(','),
    ].join(camp);

    final result = await _api.postSafe(
      ApiConstants.urlCobranzasLst,
      '$data${sep}LSP',
    );

    return switch (result) {
      ApiSuccess(:final data) => CobranzaPaginaModel.parse(data),
      ApiEmpty() => CobranzaPagina.vacia,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  String _fmtFecha(DateTime? d) =>
      d == null ? '' : d.toIso8601String().split('.').first;

  String _codigoChip(CobranzaChipFiltro chip) => switch (chip) {
    CobranzaChipFiltro.contado => 'C',
    CobranzaChipFiltro.credito => 'CR',
    CobranzaChipFiltro.todos || CobranzaChipFiltro.asesores => '',
  };

  // Task 'DT' — mismo endpoint urlCobranzasLst, body numSol¯DT (mismo patrón
  // que SolicitudRemoteDatasource.getSolicitudDetalle()).
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol) async {
    final body = '$numSol${AppConstants.sepListas}DT';

    final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => CobranzaDetalleModel.parse(data),
      ApiEmpty() => null,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'UE' — [CRM].[CSV_COBRANZAS_CUD_APP]. Único endpoint para cambiar
  // estado de la cobranza; hoy solo hace algo cuando estado='2' (Facturar):
  // guarda los datos de facturación y pasa ID_ESTADO_GES a 2. Se usa tanto
  // para contado como para crédito (en crédito, después de guardarPlanCredito).
  Future<CrudResult> cambiarEstadoFacturar({
    required String numSol,
    required String estado,
    required String condicionPago, // '1' Crédito | '2' Contado
    required String fechaVencimiento, // vacío en contado
    required String ordenCompra,
    required String descripcionSugerida,
    required String hojaAceptacion,
  }) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final cabecera = [
      numSol,
      estado,
      condicionPago,
      fechaVencimiento,
      ordenCompra,
      descripcionSugerida,
      hojaAceptacion,
      _session.codUser,
      ip,
      coords,
    ].join(AppConstants.sepCampos);

    final body = [cabecera, '', 'UE'].join(AppConstants.sepListas);

    final result = await _api.postSafe(ApiConstants.urlCobranzasCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  // Task 'RC' — [CRM].[CSV_COBRANZAS_CUD_APP]. Cabecera: NUMSOL¦MONEDA¦
  // ID_USUARIO¦IP_USUARIO¦LL_USUARIO (moneda va acá, no por cuota). Detalle
  // (una fila por cuota): CORRELATIVO¦CORRELATIVO_DESC¦DIAS¦FC_VENCIMIENTO¦
  // DIA_VENCIMIENTO(siempre vacío)¦IMPORTE (con IGV incluido — el SP lo
  // divide entre (1+igv) para sacar el neto).
  Future<CrudResult> guardarPlanCredito({
    required String numSol,
    required String moneda,
    required List<CuotaPlan> cuotas,
  }) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final cabecera = [
      numSol,
      moneda,
      _session.codUser,
      ip,
      coords,
    ].join(AppConstants.sepCampos);

    final detalle = cuotas.map((c) {
      final correlativoDesc = 'Cuota${c.numeroCuota.toString().padLeft(3, '0')}';
      return [
        c.numeroCuota.toString(),
        correlativoDesc,
        diasDesdeHoy(c.fechaVencimiento).toString(),
        c.fechaVencimiento,
        '', // DIA_VENCIMIENTO — siempre vacío, igual que en el sistema web
        c.monto.toStringAsFixed(2),
      ].join(AppConstants.sepCampos);
    }).join(AppConstants.sepRegistros);

    final body = [cabecera, detalle, 'RC'].join(AppConstants.sepListas);

    final result = await _api.postSafe(ApiConstants.urlCobranzasCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }
}
