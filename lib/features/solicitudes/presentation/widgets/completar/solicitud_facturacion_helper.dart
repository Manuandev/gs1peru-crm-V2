// lib/features/solicitudes/presentation/widgets/completar/solicitud_facturacion_helper.dart
//
// Arma un DatosFacturacion completo a partir de los datos ya capturados del
// solicitante (paso 1) — único lugar con esta lógica, para que el toggle
// "Facturar al solicitante" tenga el mismo resultado sin importar si lo
// activa desde el paso 1 (antes de visitar Facturación) o si Facturación ya
// está viva en el wizard. Ver solicitudes/CLAUDE.md.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// Departamento con nombre "LIMA" (prov/dis en '00') — nunca hardcodear el
// código INEI, se resuelve por nombre contra el catálogo real de siempre.
UbigeoItem? resolverUbigeoLimaDepartamento(List<UbigeoItem> ubigeo) => ubigeo
    .where(
      (u) => u.prov == '00' && u.dis == '00' && u.nombre.trim().toUpperCase() == 'LIMA',
    )
    .firstOrNull;

// Provincia con nombre "LIMA" dentro del departamento recibido (dis en '00').
UbigeoItem? resolverUbigeoLimaProvincia(List<UbigeoItem> ubigeo, String dptoId) =>
    dptoId.isEmpty
    ? null
    : ubigeo
          .where(
            (u) =>
                u.dpto == dptoId &&
                u.prov != '00' &&
                u.dis == '00' &&
                u.nombre.trim().toUpperCase() == 'LIMA',
          )
          .firstOrNull;

// Tipos de documento que ofrece el combo de Facturación — jerarquía pedida
// por negocio (2026-09-14): País → Comprobante → Tipo documento.
//   1. País: Perú → esNacional; otro país → !esNacional.
//   2. Comprobante: Factura → esFactura; Boleta → esBoleta.
// "Sin documento" y "Sin RUC" nunca aplican en Facturación. Si el SP
// desplegado todavía no manda PARTIDAM/PARTIDAO (`tieneReglas` en false para
// todo el catálogo), se mantiene el criterio anterior (Factura exige RUC).
List<TipoDocumentoItem> filtrarTiposDocumentoFacturacion({
  required List<TipoDocumentoItem> todos,
  required bool esExtranjero,
  required String comprobanteId,
  required ValoresCRMItem valoresDefecto,
}) {
  final hayReglas = todos.any((t) => t.tieneReglas);
  final porPais = todos
      .where(
        (t) =>
            t.id != valoresDefecto.idTipoDocSnd &&
            t.id != valoresDefecto.idTipDocSnr &&
            (esExtranjero ? !t.esNacional : t.esNacional),
      )
      .toList();

  if (!hayReglas) {
    if (!esExtranjero && comprobanteId == valoresDefecto.idTipoFactura) {
      return todos.where((t) => t.id == valoresDefecto.idTipoDocRuc).toList();
    }
    return porPais.isNotEmpty ? porPais : todos;
  }

  if (comprobanteId == valoresDefecto.idTipoFactura) {
    return porPais.where((t) => t.esFactura).toList();
  }
  if (comprobanteId == valoresDefecto.idTipoBoleta) {
    return porPais.where((t) => t.esBoleta).toList();
  }
  return porPais;
}

DatosFacturacion construirFacturacionDesdeSolicitante({
  required DatosSolicitante solicitante,
  required String tipoPersona,
  required CatalogsLoaded catalogos,
  // Moneda no viene del solicitante — se preserva la ya elegida (si el
  // asesor la tocó en Facturación antes de este re-aplicado) o cae a la
  // moneda bloqueada por la negociación de origen (SolicitudFormState.
  // idMonedaBloqueada), igual que el default "sin datos" de este paso.
  String? monedaIdActual,
  String? idMonedaBloqueada,
  // Dirección/ubigeo de SUNAT del RUC que se factura (2026-09-18) — ya
  // traídos por la búsqueda del paso 1 (caché por RUC), sin pedirlos de
  // nuevo. Vacíos → Dirección vacía y Lima/Lima por defecto.
  String direccion = '',
  String ubigeoCodigo = '',
}) {
  final valoresDefecto = catalogos.valoresDefecto;
  final esJuridica = tipoPersona == 'juridica';

  String comprobanteId = '';
  String comprobanteLabel = '';
  String tipoDocId = '';
  String tipoDocLabel = '';
  String numDoc;
  String nombresRazon;
  String apellidoPaterno = '';
  String apellidoMaterno = '';

  if (esJuridica) {
    // Jurídica solo puede facturar con RUC — Factura + RUC + Razón social
    // ya capturados en "Información comercial" (paso 1), no los datos
    // personales del solicitante.
    final factura = catalogos.comprobantes
        .where((c) => c.id == valoresDefecto.idTipoFactura)
        .firstOrNull;
    if (factura != null) {
      comprobanteId = factura.id;
      comprobanteLabel = factura.nombre;
    }
    final ruc = catalogos.tiposDocumento
        .where((t) => t.id == valoresDefecto.idTipoDocRuc)
        .firstOrNull;
    if (ruc != null) {
      tipoDocId = ruc.id;
      tipoDocLabel = ruc.abreviatura;
    }
    numDoc = solicitante.ruc;
    nombresRazon = solicitante.razonSocial;
  } else if (DocumentoValidationUtils.esRuc(
    solicitante.tipoDocId,
    valoresDefecto,
  )) {
    // Solicitante con tipo RUC pero sin Información comercial (Natural,
    // 2026-09-18) — Boleta + su RUC + la Razón social guardada en `nombres`.
    final boleta = catalogos.comprobantes
        .where((c) => c.id == valoresDefecto.idTipoBoleta)
        .firstOrNull;
    if (boleta != null) {
      comprobanteId = boleta.id;
      comprobanteLabel = boleta.nombre;
    }
    tipoDocId = solicitante.tipoDocId;
    tipoDocLabel = solicitante.tipoDocLabel;
    numDoc = solicitante.numDoc;
    nombresRazon = solicitante.nombres;
  } else {
    final boleta = catalogos.comprobantes
        .where((c) => c.id == valoresDefecto.idTipoBoleta)
        .firstOrNull;
    if (boleta != null) {
      comprobanteId = boleta.id;
      comprobanteLabel = boleta.nombre;
    }
    tipoDocId = solicitante.tipoDocId;
    tipoDocLabel = solicitante.tipoDocLabel;
    numDoc = solicitante.numDoc;
    nombresRazon = solicitante.nombres;
    apellidoPaterno = solicitante.apellidoPaterno;
    apellidoMaterno = solicitante.apellidoMaterno;
  }

  final paisDefecto = catalogos.paises
      .where((p) => p.id == valoresDefecto.idPais)
      .firstOrNull;
  final paisCelular = catalogos.paises
      .where((p) => p.codigoTelefono == solicitante.celularCodigoTelefono)
      .firstOrNull;

  // Departamento/Provincia siempre por defecto Lima/Lima — pedido de
  // negocio, sin importar jurídica/natural ni si "Facturar al solicitante"
  // está activo.
  final ubigeoLimaDpto = resolverUbigeoLimaDepartamento(catalogos.ubigeo);
  final ubigeoLimaProv = resolverUbigeoLimaProvincia(
    catalogos.ubigeo,
    ubigeoLimaDpto?.dpto ?? '',
  );
  // Ubigeo de SUNAT (6 dígitos dpto+prov+dis) resuelto contra el catálogo;
  // si algún nivel no existe se queda el default Lima/Lima.
  final ubigeoSunat = resolverUbigeoPorCodigo(catalogos.ubigeo, ubigeoCodigo);

  String monedaId = (monedaIdActual ?? '').isNotEmpty ? monedaIdActual! : '';
  String moneda = '';
  if (monedaId.isNotEmpty) {
    moneda =
        catalogos.monedas.where((m) => m.id == monedaId).firstOrNull?.nombre ??
        '';
  } else if ((idMonedaBloqueada ?? '').isNotEmpty) {
    final monedaDefecto = catalogos.monedas
        .where((m) => m.id == idMonedaBloqueada)
        .firstOrNull;
    if (monedaDefecto != null) {
      monedaId = monedaDefecto.id;
      moneda = monedaDefecto.nombre;
    }
  }

  return DatosFacturacion(
    comprobanteId: comprobanteId,
    comprobante: comprobanteLabel,
    paisId: paisDefecto?.id ?? '',
    pais: paisDefecto?.nombre ?? '',
    monedaId: monedaId,
    moneda: moneda,
    tipoDocId: tipoDocId,
    tipoDocLabel: tipoDocLabel,
    numDoc: numDoc,
    nacionalidadId: solicitante.nacionalidadId,
    nacionalidad: solicitante.nacionalidad,
    nombresRazon: nombresRazon,
    apellidoPaterno: apellidoPaterno,
    apellidoMaterno: apellidoMaterno,
    celular: solicitante.celular,
    celularCodigoTelefono: paisCelular?.codigoTelefono ?? '',
    correo: solicitante.correo,
    direccion: direccion,
    actividadEconomica: '',
    nit: '',
    observaciones: '',
    ubigeoDptoId: ubigeoSunat?.dpto.dpto ?? ubigeoLimaDpto?.dpto ?? '',
    ubigeoDptoNombre: ubigeoSunat?.dpto.nombre ?? ubigeoLimaDpto?.nombre ?? '',
    ubigeoProvId: ubigeoSunat?.prov.prov ?? ubigeoLimaProv?.prov ?? '',
    ubigeoProvNombre:
        ubigeoSunat?.prov.nombre ?? ubigeoLimaProv?.nombre ?? '',
    ubigeoDisId: ubigeoSunat?.dis.dis ?? '',
    ubigeoDisNombre: ubigeoSunat?.dis.nombre ?? '',
  );
}

// Departamento/Provincia/Distrito de un código de ubigeo de 6 dígitos
// (SUNAT) — null si el código no es válido o algún nivel no está en el
// catálogo.
({UbigeoItem dpto, UbigeoItem prov, UbigeoItem dis})? resolverUbigeoPorCodigo(
  List<UbigeoItem> ubigeo,
  String codigo,
) {
  final c = codigo.trim();
  if (c.length != 6) return null;
  final dpto = c.substring(0, 2);
  final prov = c.substring(2, 4);
  final dis = c.substring(4, 6);
  const nivelVacio = '00';
  final itemDpto = ubigeo
      .where(
        (u) => u.dpto == dpto && u.prov == nivelVacio && u.dis == nivelVacio,
      )
      .firstOrNull;
  final itemProv = ubigeo
      .where((u) => u.dpto == dpto && u.prov == prov && u.dis == nivelVacio)
      .firstOrNull;
  final itemDis = ubigeo
      .where((u) => u.dpto == dpto && u.prov == prov && u.dis == dis)
      .firstOrNull;
  if (itemDpto == null || itemProv == null || itemDis == null) return null;
  return (dpto: itemDpto, prov: itemProv, dis: itemDis);
}
