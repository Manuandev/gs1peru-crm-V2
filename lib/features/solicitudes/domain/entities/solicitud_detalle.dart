// lib/features/solicitudes/domain/entities/solicitud_detalle.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';

// CRM.T_LEAD_SEGUIMIENTO + CRM.T_LEAD_ACTIVIDAD del lead asociado al NUMSOL —
// mismo patrón que HistorialCobranza.
class HistorialSolicitud {
  final String origen;
  final String titulo;
  final String descripcion;
  final String fecha;

  const HistorialSolicitud({
    required this.origen,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });
}

// Detalle de solo lectura de una solicitud ya guardada — los campos que
// pinta SolicitudDetalleView (participante, facturación, historial) más la
// cabecera (nombre, estado, oportunidad, canal, asesor, monto). Todo sale de
// UNA sola llamada al task 'DV' — hasta el 2026-09-11 la cabecera se sacaba
// de la lista completa 'LS' en una segunda llamada.
// A diferencia del wizard (SolicitudDetalleModel, task 'DT', solo ids de
// catálogo), acá los campos ya vienen resueltos a descripción desde el
// propio SP.
class SolicitudDetalle {
  final String numSol;

  // ── Participante ──
  // Id crudo de TipoDocumentoItem (SYSTABEXTER02 CODTABLA='F01') — se
  // resuelve a abreviatura ("DNI"/"CE"/"RUC"...) contra CatalogsBloc, mismo
  // catálogo que ya usa el wizard. El SP no trae la descripción.
  final String tipoDocumentoId;
  final String numDoc;
  final String cargo;
  final String celular;
  final String correo;

  // ── Facturación ──
  final String facTipoComprobante; // descripción, ej. "Factura"
  final String facRazonSocial;
  final String facRuc;
  final String facDireccion;
  // Datos de facturación para persona natural (Boleta) — el SP solo llena
  // RUCEMPRE/NOMEMPRE cuando el tipo de documento de facturación es RUC; en
  // cualquier otro caso llena estos 3 campos en su lugar (mutuamente
  // excluyentes, mismo criterio que el CUD/wizard). Ver facTieneRuc.
  final String facNumDoc;
  final String facNombres;
  final String facApellidoPaterno;
  final String facApellidoMaterno;

  final List<HistorialSolicitud> historial;

  // Cabecera fresca (sección [2] del 'DV', misma fila que el 'LSP'). Null si
  // el SP desplegado todavía no trae esa sección — la vista cae al Solicitud
  // de navegación.
  final Solicitud? cabecera;

  const SolicitudDetalle({
    required this.numSol,
    required this.tipoDocumentoId,
    required this.numDoc,
    required this.cargo,
    required this.celular,
    required this.correo,
    required this.facTipoComprobante,
    required this.facRazonSocial,
    required this.facRuc,
    required this.facDireccion,
    this.facNumDoc = '',
    this.facNombres = '',
    this.facApellidoPaterno = '',
    this.facApellidoMaterno = '',
    this.historial = const [],
    this.cabecera,
  });

  // true si la facturación es con RUC (Factura, razón social) — false si es
  // con documento de persona natural (Boleta, nombre completo).
  bool get facTieneRuc => facRuc.isNotEmpty;

  String get facNombreCompleto =>
      '$facNombres $facApellidoPaterno $facApellidoMaterno'
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  SolicitudDetalle copyWith({
    String? tipoDocumentoId,
    String? numDoc,
    String? cargo,
    String? celular,
    String? correo,
    String? facTipoComprobante,
    String? facRazonSocial,
    String? facRuc,
    String? facDireccion,
    String? facNumDoc,
    String? facNombres,
    String? facApellidoPaterno,
    String? facApellidoMaterno,
    List<HistorialSolicitud>? historial,
  }) {
    return SolicitudDetalle(
      numSol: numSol,
      tipoDocumentoId: tipoDocumentoId ?? this.tipoDocumentoId,
      numDoc: numDoc ?? this.numDoc,
      cargo: cargo ?? this.cargo,
      celular: celular ?? this.celular,
      correo: correo ?? this.correo,
      facTipoComprobante: facTipoComprobante ?? this.facTipoComprobante,
      facRazonSocial: facRazonSocial ?? this.facRazonSocial,
      facRuc: facRuc ?? this.facRuc,
      facDireccion: facDireccion ?? this.facDireccion,
      facNumDoc: facNumDoc ?? this.facNumDoc,
      facNombres: facNombres ?? this.facNombres,
      facApellidoPaterno: facApellidoPaterno ?? this.facApellidoPaterno,
      facApellidoMaterno: facApellidoMaterno ?? this.facApellidoMaterno,
      historial: historial ?? this.historial,
      cabecera: cabecera,
    );
  }
}
