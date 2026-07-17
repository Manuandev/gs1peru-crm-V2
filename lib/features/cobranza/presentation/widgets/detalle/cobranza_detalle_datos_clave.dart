// lib/features/cobranza/presentation/widgets/detalle/cobranza_detalle_datos_clave.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleDatosClave extends StatelessWidget {
  final CobranzaDetalle detalle;
  const CobranzaDetalleDatosClave({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    final filas = [
      _FilaDato(
        icono: AppIcons.file,
        label: 'Boleta / Factura',
        valor: detalle.tipoComprobante,
      ),
      if (detalle.moneda.isNotEmpty)
        _FilaDato(
          icono: AppIcons.moneda,
          label: 'Moneda',
          valor:
              detalle.moneda, //resolverSimboloMoneda(context, detalle.moneda),
        ),
      if (detalle.correo.isNotEmpty)
        _FilaDato(
          icono: AppIcons.email,
          label: 'Correo',
          valor: detalle.correo,
          esTappable: true,
          onTap: () => Clipboard.setData(ClipboardData(text: detalle.correo)),
        ),
      if (detalle.celular.isNotEmpty)
        _FilaDato(
          icono: AppIcons.phone,
          label: 'Celular',
          valor: detalle.celular,
          esTappable: true,
          onTap: () => Clipboard.setData(ClipboardData(text: detalle.celular)),
        ),
      // Observación: el backend no la persiste hoy (confirmado con negocio) —
      // no se muestra hasta que exista una columna real para guardarla.
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documentos de facturación',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (detalle.sinFacturacion)
            const AppEmptyView(message: 'No tiene registros en facturación')
          else ...[
            ...filas.map((fila) => _FilaDatoWidget(fila: fila)),
            if (detalle.archivos.isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              ...detalle.archivos.map((a) => _FilaArchivo(archivo: a)),
            ],
          ],
        ],
      ),
    );
  }
}

class _FilaDatoWidget extends StatelessWidget {
  final _FilaDato fila;
  const _FilaDatoWidget({required this.fila});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: fila.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              fila.icono,
              size: AppSizing.iconSm,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                fila.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                fila.valor,
                style: AppTextStyles.labelSmall.copyWith(
                  color: fila.esTappable
                      ? AppColors.info
                      : AppColors.textPrimary,
                  fontWeight: fila.esTappable
                      ? AppTextStyles.weightMedium
                      : AppTextStyles.weightRegular,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
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

class _FilaDato {
  final IconData icono;
  final String label;
  final String valor;
  final bool esTappable;
  final VoidCallback? onTap;

  const _FilaDato({
    required this.icono,
    required this.label,
    required this.valor,
    this.esTappable = false,
    this.onTap,
  });
}
