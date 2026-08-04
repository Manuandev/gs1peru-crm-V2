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
    direccion: '',
    actividadEconomica: '',
    nit: '',
    observaciones: '',
    ubigeoDptoId: ubigeoLimaDpto?.dpto ?? '',
    ubigeoDptoNombre: ubigeoLimaDpto?.nombre ?? '',
    ubigeoProvId: ubigeoLimaProv?.prov ?? '',
    ubigeoProvNombre: ubigeoLimaProv?.nombre ?? '',
    ubigeoDisId: '',
    ubigeoDisNombre: '',
  );
}
