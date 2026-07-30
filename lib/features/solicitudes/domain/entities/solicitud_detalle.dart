// lib/features/solicitudes/domain/entities/solicitud_detalle.dart

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

// Detalle de solo lectura de una solicitud ya guardada — únicamente los
// campos que pinta SolicitudDetalleView (participante, facturación,
// historial). El resto (nombre, estado, oportunidad, canal, asesor) ya
// llega en el Solicitud de la lista ('LS') y no se vuelve a traer acá.
// A diferencia del wizard (SolicitudDetalleModel, task 'DT', solo ids de
// catálogo), acá los campos ya vienen resueltos a descripción desde el
// propio SP (task 'DV').
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
  });

  // true si la facturación es con RUC (Factura, razón social) — false si es
  // con documento de persona natural (Boleta, nombre completo).
  bool get facTieneRuc => facRuc.isNotEmpty;

  String get facNombreCompleto =>
      '$facNombres $facApellidoPaterno $facApellidoMaterno'
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
}
