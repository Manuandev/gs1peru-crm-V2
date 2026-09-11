// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_datos_clave.dart
//
// Sección "Datos de facturación" del detalle de cobro — mismas filas y mismo
// diseño que "Datos de facturación" del Detalle de Solicitud (AppSeccionCard
// + AppFilaInfo, core). Correo/celular se copian al tocarlos.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleDatosClave extends StatelessWidget {
  final CobranzaDetalle detalle;
  const CobranzaDetalleDatosClave({super.key, required this.detalle});

  void _copiar(BuildContext context, String texto, String que) {
    Clipboard.setData(ClipboardData(text: texto));
    AppSnackBar.info(context, '$que copiado');
  }

  @override
  Widget build(BuildContext context) {
    if (detalle.sinFacturacion) {
      return const AppSeccionCard(
        colorIcono: AppColors.purple,
        icono: AppIcons.receipt,
        titulo: 'Datos de facturación',
        children: [
          AppSeccionVacia(
            icono: AppIcons.receipt,
            color: AppColors.purple,
            titulo: 'Sin datos de facturación',
            mensaje: 'Esta cobranza todavía no tiene datos de facturación '
                'registrados.',
          ),
        ],
      );
    }

    // Solo las filas con dato. Factura (con RUC) → RUC + razón social;
    // Boleta (sin RUC) → N° documento + nombre — mutuamente excluyentes,
    // mismo criterio que el Detalle de Solicitud (facTieneRuc).
    // Observación: el backend no la persiste hoy (confirmado con negocio).
    final filas = <({String etiqueta, String valor, VoidCallback? onTap})>[
      (
        etiqueta: 'Tipo de comprobante',
        valor: detalle.tipoComprobante,
        onTap: null,
      ),
      if (detalle.facTieneRuc) ...[
        (etiqueta: 'RUC', valor: detalle.facRuc, onTap: null),
        if (detalle.facRazonSocial.isNotEmpty)
          (
            etiqueta: 'Razón social',
            valor: detalle.facRazonSocial,
            onTap: null,
          ),
      ] else ...[
        if (detalle.facNumDoc.isNotEmpty)
          (etiqueta: 'N° documento', valor: detalle.facNumDoc, onTap: null),
        if (detalle.facNombreCompleto.isNotEmpty)
          (
            etiqueta: 'Nombre',
            valor: detalle.facNombreCompleto,
            onTap: null,
          ),
      ],
      if (detalle.facDireccion.isNotEmpty)
        (
          etiqueta: 'Dirección fiscal',
          valor: detalle.facDireccion,
          onTap: null,
        ),
      if (detalle.moneda.isNotEmpty)
        (etiqueta: 'Moneda', valor: detalle.moneda, onTap: null),
      if (detalle.correo.isNotEmpty)
        (
          etiqueta: 'Correo',
          valor: detalle.correo,
          onTap: () => _copiar(context, detalle.correo, 'Correo'),
        ),
      if (detalle.celular.isNotEmpty)
        (
          etiqueta: 'Celular',
          valor: detalle.celular,
          onTap: () => _copiar(context, detalle.celular, 'Celular'),
        ),
    ];

    return AppSeccionCard(
      colorIcono: AppColors.purple,
      icono: AppIcons.receipt,
      titulo: 'Datos de facturación',
      children: [
        for (int i = 0; i < filas.length; i++)
          AppFilaInfo(
            etiqueta: filas[i].etiqueta,
            valor: filas[i].valor,
            onTap: filas[i].onTap,
            // Sin divisor en la última fila, salvo que abajo vengan archivos.
            mostrarDivisor:
                i < filas.length - 1 || detalle.archivos.isNotEmpty,
          ),
        if (detalle.archivos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          ...detalle.archivos.map((a) => _FilaArchivo(archivo: a)),
        ],
      ],
    );
  }
}

// Fila de un archivo adjunto (voucher/factura/etc.) — reutiliza fileIcon/
// fileColor (core) por extensión, igual que en chat/multimedia.
class _FilaArchivo extends StatelessWidget {
  final ArchivoCobranza archivo;
  const _FilaArchivo({required this.archivo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            fileIcon(archivo.nombreCompleto),
            size: AppSizing.iconSm,
            color: fileColor(archivo.nombreCompleto),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              archivo.nombreCompleto,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            archivo.tipo.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
