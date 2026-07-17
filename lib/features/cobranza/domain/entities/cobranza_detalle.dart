// lib/features/cobranza/domain/entities/cobranza_detalle.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalle {
  final String idCobranza; // NUMSOL
  final String nombre;
  final String apellido;
  final String apellidoMaterno;
  final int idOportunidad;
  final String oportunidad;
  final String ejecutivo;
  final double montoTotal;

  // Estado de gestión — mismo id crudo que Cobranza (ID_ESTADO_GES, 0-5,
  // ver DBO.[edu.TIP_ESTADO_GES]). estado es la descripción tal cual la
  // manda el backend.
  final int idEstado;
  final String estado;

  final String idCondicion; // 'C' | 'CR'
  final String condicion;
  final String fechaSolicitud;
  final String tipoComprobante;
  final String moneda;
  final String correo;
  final String celular;
  final int idChatCab;
  final List<ArchivoCobranza> archivos;
  final List<HistorialCobranza> historial;

  String get nombreCompleto =>
      [nombre, apellido, apellidoMaterno].where((p) => p.isNotEmpty).join(' ');

  // true si el join de facturación no trajo ningún dato (registro vacío/sin
  // completar todavía) — usado para mostrar un mensaje en vez de una fila
  // "Boleta / Factura" sin valor.
  bool get sinFacturacion =>
      tipoComprobante.isEmpty &&
      moneda.isEmpty &&
      correo.isEmpty &&
      celular.isEmpty;

  const CobranzaDetalle({
    required this.idCobranza,
    required this.nombre,
    required this.apellido,
    this.apellidoMaterno = '',
    this.idOportunidad = 0,
    required this.oportunidad,
    required this.ejecutivo,
    required this.montoTotal,
    required this.idEstado,
    required this.estado,
    required this.idCondicion,
    required this.condicion,
    required this.fechaSolicitud,
    required this.tipoComprobante,
    this.moneda = '',
    this.correo = '',
    this.celular = '',
    this.idChatCab = 0,
    this.archivos = const [],
    required this.historial,
  });
}
