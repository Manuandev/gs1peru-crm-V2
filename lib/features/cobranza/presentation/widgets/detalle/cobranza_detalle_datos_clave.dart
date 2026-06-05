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
      if (detalle.correo != null)
        _FilaDato(
          icono: AppIcons.email,
          label: 'Correo',
          valor: detalle.correo!,
          esTappable: true,
          onTap: () => Clipboard.setData(ClipboardData(text: detalle.correo!)),
        ),
      if (detalle.celular != null)
        _FilaDato(
          icono: AppIcons.phone,
          label: 'Celular',
          valor: detalle.celular!,
          esTappable: true,
          onTap: () => Clipboard.setData(ClipboardData(text: detalle.celular!)),
        ),
      if (detalle.observacion != null)
        _FilaDato(
          icono: AppIcons.file,
          label: 'Observación',
          valor: detalle.observacion!,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
            'Datos clave',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...filas.map((fila) => _FilaDatoWidget(fila: fila)),
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                fila.valor,
                style: AppTextStyles.bodySmall.copyWith(
                  color: fila.esTappable ? AppColors.info : AppColors.textPrimary,
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
