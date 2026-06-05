// lib/features/cobranza/domain/entities/cobranza_detalle.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalle {
  final int idCobranza;
  final String nombre;
  final String apellido;
  final String oportunidad;
  final String ejecutivo;
  final double montoTotal;
  final String idEstado;
  final String estado;
  final String idCondicion;
  final String condicion;
  final String fechaSolicitud;
  final String tipoComprobante;
  final String? correo;
  final String? celular;
  final String? observacion;
  final List<HistorialCobranza> historial;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const CobranzaDetalle({
    required this.idCobranza,
    required this.nombre,
    required this.apellido,
    required this.oportunidad,
    required this.ejecutivo,
    required this.montoTotal,
    required this.idEstado,
    required this.estado,
    required this.idCondicion,
    required this.condicion,
    required this.fechaSolicitud,
    required this.tipoComprobante,
    this.correo,
    this.celular,
    this.observacion,
    required this.historial,
  });
}
