// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_secciones.dart
//
// Secciones "Datos del participante" y "Datos de facturación" de
// SolicitudDetalleView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SeccionDatosParticipante extends StatelessWidget {
  final SolicitudDetalle detalle;

  const SeccionDatosParticipante({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    // El SP trae el id crudo de TipoDocumentoItem (SYSTABEXTER02 CODTABLA=
    // 'F01') — se resuelve a abreviatura ("DNI"/"CE"/"RUC"...) contra el
    // mismo catálogo que ya usa el wizard, no viene resuelto del backend.
    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final tipoDoc = tiposDocumento
        .where((t) => t.id == detalle.tipoDocumentoId)
        .firstOrNull;

    return SeccionCard(
      colorIcono: AppColors.primary,
      icono: AppIcons.user,
      titulo: 'Datos del participante',
      children: [
        FilaInfo(etiqueta: 'Correo', valor: detalle.correo),
        FilaInfo(etiqueta: 'Celular', valor: detalle.celular),
        FilaInfo(
          etiqueta: 'Documento',
          valor: '${tipoDoc?.abreviatura ?? ''} ${detalle.numDoc}'.trim(),
        ),
        FilaInfo(
          etiqueta: 'Cargo',
          valor: detalle.cargo,
          mostrarDivisor: false,
        ),
      ],
    );
  }
}

class SeccionDatosFacturacion extends StatelessWidget {
  final SolicitudDetalle detalle;

  const SeccionDatosFacturacion({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return SeccionCard(
      colorIcono: AppColors.purple,
      icono: AppIcons.receipt,
      titulo: 'Datos de facturación',
      children: [
        FilaInfo(
          etiqueta: 'Tipo de comprobante',
          valor: detalle.facTipoComprobante,
        ),
        // Factura (con RUC) → RUC + Razón social. Boleta (sin RUC) → N°
        // documento + Nombre — mutuamente excluyentes, mismo criterio que
        // usa el wizard (ver DatosFacturacion.esRuc en CLAUDE.md).
        if (detalle.facTieneRuc) ...[
          FilaInfo(etiqueta: 'RUC', valor: detalle.facRuc),
          FilaInfo(etiqueta: 'Razón social', valor: detalle.facRazonSocial),
        ] else ...[
          FilaInfo(etiqueta: 'N° documento', valor: detalle.facNumDoc),
          FilaInfo(etiqueta: 'Nombre', valor: detalle.facNombreCompleto),
        ],
        FilaInfo(
          etiqueta: 'Dirección fiscal',
          valor: detalle.facDireccion,
          mostrarDivisor: false,
        ),
      ],
    );
  }
}
