// lib/features/cobranza/data/datasources/remote/cobranza_remote_datasource.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRemoteDatasource {
  // TODO: activar cuando el endpoint esté listo
  // final ApiClient _api = ApiClient();
  // final _session = SessionService();

  Future<List<CobranzaModel>> getCobranzas() async {
    // TODO: reemplazar mock con llamada real:
    // final String body =
    //     '${[_session.codUser, _session.isModerador ? 1 : 0, 'L'].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';
    // final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);
    // return switch (result) {
    //   ApiSuccess(:final data) => CobranzaModel.parseList(data),
    //   ApiEmpty() => [],
    //   ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
    //   ApiError(:final message) => throw AppException(message),
    // };

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockCobranzas();
  }

  List<CobranzaModel> _mockCobranzas() => [
        const CobranzaModel(
          idCobranza: 1,
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
          idCobranza: 2,
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
          idCobranza: 3,
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
          idCobranza: 4,
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
          idCobranza: 5,
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
          idCobranza: 6,
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
          idCobranza: 7,
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
}
