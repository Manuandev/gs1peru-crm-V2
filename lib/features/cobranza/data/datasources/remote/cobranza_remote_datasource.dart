// lib/features/cobranza/data/datasources/remote/cobranza_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<CobranzaModel>> getCobranzas() async {
    // final String body =
    //     '${[_session.codUser, _session.isModerador ? 1 : 0].join(AppConstants.sepCampos)}${AppConstants.sepListas}L';

    // final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    // return switch (result) {
    //   ApiSuccess(:final data) => CobranzaModel.parseList(data),
    //   ApiEmpty() => [],
    //   ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
    //   ApiError(:final message) => throw AppException(message),
    // };
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockCobranzas();
  }

  Future<CobranzaDetalle?> getDetalleCobranza(String numSol) async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0, numSol].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';

    final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => CobranzaDetalleModel.parse(data),
      ApiEmpty() => null,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  List<CobranzaModel> _mockCobranzas() => [
    const CobranzaModel(
      numSol: '1',
      nombre: 'Roberto Cesar',
      apellido: 'Merino Ascarrunz',
      evento: 'Curso IA en la gestión de la cadena de suministro',
      montoTotal: 603.39,
      ejecutivo: 'Julio Flores',
      asignadoA: 'jflores',
      idCondicion: 'C',
      condicion: 'Contado',
      fecha: '14/05/2026',
      idEstado: 'F',
      estado: 'Facturar',
      telefono: '987654321',
    ),
    const CobranzaModel(
      numSol: '2',
      nombre: 'Lorena Gisella',
      apellido: 'Yauri Morillo',
      evento: 'Curso IA en la gestión de la cadena de suministro',
      montoTotal: 532.20,
      ejecutivo: 'Julio Flores',
      asignadoA: 'jflores',
      idCondicion: 'C',
      condicion: 'Contado',
      fecha: '14/05/2026',
      idEstado: 'PD',
      estado: 'Pend. documento',
      telefono: '987654322',
    ),
    const CobranzaModel(
      numSol: '3',
      nombre: 'Oscar Emilio',
      apellido: 'Begazo Ramos',
      evento: 'Curso IA en la gestión de la cadena de suministro',
      montoTotal: 497.00,
      ejecutivo: 'Julio Flores',
      asignadoA: 'jflores',
      idCondicion: 'C',
      condicion: 'Contado',
      fecha: '14/05/2026',
      fechaVencimiento: '19/05/2026',
      diasVencimiento: 3,
      idEstado: 'PP',
      estado: 'Pend. pago',
      telefono: '987654323',
    ),
    const CobranzaModel(
      numSol: '4',
      nombre: 'Arturo Pelayo',
      apellido: 'Aliaga Nicacio',
      evento: 'Curso IA en la gestión de la cadena de suministro',
      montoTotal: 567.80,
      ejecutivo: 'Julio Flores',
      asignadoA: 'jflores',
      idCondicion: 'C',
      condicion: 'Contado',
      fecha: '14/05/2026',
      idEstado: 'CA',
      estado: 'Cancelado',
      telefono: '987654324',
    ),
    const CobranzaModel(
      numSol: '5',
      nombre: 'Marco Antonio',
      apellido: 'Angulo Noriega',
      evento: 'Curso IA en la gestión de la cadena de suministro',
      montoTotal: 720.00,
      ejecutivo: 'Ana Torres',
      asignadoA: 'atorres',
      idCondicion: 'CR',
      condicion: 'Crédito',
      fecha: '14/05/2026',
      fechaVencimiento: '28/05/2026',
      diasVencimiento: 12,
      idEstado: 'F',
      estado: 'Facturar',
      telefono: '987654325',
    ),
    const CobranzaModel(
      numSol: '6',
      nombre: 'Carmen Rosa',
      apellido: 'Villanueva Pérez',
      evento: 'Certificación GS1 Estándares Globales',
      montoTotal: 890.50,
      ejecutivo: 'Ana Torres',
      asignadoA: 'atorres',
      idCondicion: 'CR',
      condicion: 'Crédito',
      fecha: '10/05/2026',
      fechaVencimiento: '17/05/2026',
      diasVencimiento: 1,
      idEstado: 'PP',
      estado: 'Pend. pago',
      telefono: '987654326',
    ),
    const CobranzaModel(
      numSol: '7',
      nombre: 'Diego Armando',
      apellido: 'Quispe Huanca',
      evento: 'Certificación GS1 Estándares Globales',
      montoTotal: 350.00,
      ejecutivo: 'Julio Flores',
      asignadoA: 'jflores',
      idCondicion: 'C',
      condicion: 'Contado',
      fecha: '08/05/2026',
      idEstado: 'PD',
      estado: 'Pend. documento',
      telefono: '987654327',
    ),
  ];

  Future<CrudResult> guardarBorrador(int idCobranza) async {
    // TODO: conectar con endpoint real
    // final body = '${[_session.codUser, idCobranza, 'GB'].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';
    // final raw = await _api.postJsonGetText(ApiConstants.urlCobranzasLst, body);
    // return parseCrudResponse(raw);
    await Future.delayed(const Duration(milliseconds: 500));
    return const CrudOk('Borrador guardado correctamente');
  }

  Future<CrudResult> facturarContado(int idCobranza) async {
    // TODO: conectar con endpoint real
    // final body = '${[_session.codUser, idCobranza, 'FC'].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';
    // final raw = await _api.postJsonGetText(ApiConstants.urlCobranzasLst, body);
    // return parseCrudResponse(raw);
    await Future.delayed(const Duration(milliseconds: 500));
    return const CrudOk('Factura generada correctamente');
  }

  Future<CrudResult> guardarPlanCredito(
    int idCobranza,
    List<CuotaPlan> cuotas,
  ) async {
    // TODO: conectar con endpoint real
    // Serializar: idCobranza + cuotas separadas por AppConstants.sepRegistros
    // final body = ...
    // return parseCrudResponse(raw);
    await Future.delayed(const Duration(milliseconds: 500));
    return const CrudOk('Plan de crédito guardado correctamente');
  }
}
