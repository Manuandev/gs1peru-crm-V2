// lib/features/cobranza/domain/entities/cobranza_detalle.dart

import 'package:app_crm/core/utils/string/string_utils.dart';
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
  // Descripción corta de moneda (SYSTABEXTER02.descorta) — NUNCA usar para
  // decidir dólares/soles, solo para mostrar el símbolo. Usar monedaId.
  final String moneda;
  // Id real de moneda (SYSTABEXTER02.codargu) — agregado 2026-08-19.
  final String monedaId;
  final String correo;
  final String celular;
  final int idChatCab;

  // Datos de facturación (EVT.T_TECMSOLINSCRIPCION01_FACTURACION, campos
  // 19-25 del task 'DT', agregados 2026-09-11) — mismos que muestra el
  // Detalle de Solicitud: Factura (con RUC) → RUC + razón social; Boleta
  // (sin RUC) → N° documento + nombre. Mutuamente excluyentes.
  final String facNumDoc;
  final String facNombres;
  final String facApePaterno;
  final String facApeMaterno;
  final String facRuc;
  final String facRazonSocial;
  final String facDireccion;

  String get nombreCompleto => [nombre, apellido, apellidoMaterno]
      .where((p) => p.isNotEmpty)
      .join(' ')
      .aTitulo;

  // Mismo criterio que SolicitudDetalle.facTieneRuc — ambos grupos de campos
  // son excluyentes en el guardado, el RUC decide cuál mostrar.
  bool get facTieneRuc => facRuc.isNotEmpty;

  String get facNombreCompleto => [facNombres, facApePaterno, facApeMaterno]
      .where((p) => p.isNotEmpty)
      .join(' ')
      .aTitulo;

  final List<ArchivoCobranza> archivos;
  final List<HistorialCobranza> historial;

  // true si el join de facturación no trajo ningún dato (registro vacío/sin
  // completar todavía) — usado para mostrar un mensaje en vez de una fila
  // "Boleta / Factura" sin valor.
  bool get sinFacturacion =>
      tipoComprobante.isEmpty &&
      moneda.isEmpty &&
      correo.isEmpty &&
      celular.isEmpty &&
      facRuc.isEmpty &&
      facNumDoc.isEmpty;

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
    this.monedaId = '',
    this.correo = '',
    this.celular = '',
    this.idChatCab = 0,
    this.facNumDoc = '',
    this.facNombres = '',
    this.facApePaterno = '',
    this.facApeMaterno = '',
    this.facRuc = '',
    this.facRazonSocial = '',
    this.facDireccion = '',
    this.archivos = const [],
    required this.historial,
  });

  CobranzaDetalle copyWith({
    int? idEstado,
    String? estado,
    String? idCondicion,
    String? condicion,
  }) {
    return CobranzaDetalle(
      idCobranza: idCobranza,
      nombre: nombre,
      apellido: apellido,
      apellidoMaterno: apellidoMaterno,
      idOportunidad: idOportunidad,
      oportunidad: oportunidad,
      ejecutivo: ejecutivo,
      montoTotal: montoTotal,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idCondicion: idCondicion ?? this.idCondicion,
      condicion: condicion ?? this.condicion,
      fechaSolicitud: fechaSolicitud,
      tipoComprobante: tipoComprobante,
      moneda: moneda,
      monedaId: monedaId,
      correo: correo,
      celular: celular,
      idChatCab: idChatCab,
      facNumDoc: facNumDoc,
      facNombres: facNombres,
      facApePaterno: facApePaterno,
      facApeMaterno: facApeMaterno,
      facRuc: facRuc,
      facRazonSocial: facRazonSocial,
      facDireccion: facDireccion,
      archivos: archivos,
      historial: historial,
    );
  }
}
