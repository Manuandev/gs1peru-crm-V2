// lib/features/lead/presentation/widgets/edit_lead/edit_lead_financiera_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadFinancieraSection extends StatelessWidget {
  final TextEditingController cantidadCtrl;
  final TextEditingController precioBaseCtrl;
  final TextEditingController descuentoCtrl;
  final MonedaItem monedaItem;
  final bool isLoading;
  final ValueChanged<MonedaItem?> onMonedaChanged;
  final double subtotal;
  final double descuento;
  final double costoFinal;

  const EditLeadFinancieraSection({
    super.key,
    required this.cantidadCtrl,
    required this.precioBaseCtrl,
    required this.descuentoCtrl,
    required this.monedaItem,
    required this.isLoading,
    required this.onMonedaChanged,
    required this.subtotal,
    required this.descuento,
    required this.costoFinal,
  });

  String get _simbolo => monedaItem.simbolo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información financiera'),
        const SizedBox(height: AppSpacing.md),

        FormFieldRow(
          izquierdo: CustomComboField<MonedaItem>(
            data: AppCurrencies.all,
            label: 'Moneda',
            initialValue: monedaItem.codigo,
            onChanged: onMonedaChanged,
            enabled: !isLoading,
            dense: true,
            prefixIcon: Icon(
              AppIcons.moneda,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomTextField(
            label: 'Cantidad',
            controller: cantidadCtrl,
            enabled: !isLoading,
            dense: true,
            prefixIcon: Icon(
              AppIcons.receipt,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Precio base',
            controller: precioBaseCtrl,
            enabled: !isLoading,
            prefixText: '$_simbolo ',
            dense: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          derecho: CustomTextField(
            label: 'Descuento',
            controller: descuentoCtrl,
            enabled: !isLoading,
            prefixText: '$_simbolo ',
            dense: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Costo final',
          controller: TextEditingController(
            text: NumberFormatUtils.formatMoneda(_simbolo, costoFinal),
          ),
          enabled: false,
          dense: true,
        ),
        const SizedBox(height: AppSpacing.md),

        NegociacionResumenCard(
          subtotal: subtotal,
          montoDescuento: descuento,
          costoFinal: costoFinal,
          simbolo: _simbolo,
        ),
      ],
    );
  }
}
