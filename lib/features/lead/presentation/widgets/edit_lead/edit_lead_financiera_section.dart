// lib/features/lead/presentation/widgets/edit_lead/edit_lead_financiera_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

// Moneda, Precio base y Descuento nunca son editables por el usuario (ver
// reglas de negocio en edit_lead_portrait.dart): los tres se autocompletan
// al elegir Oportunidad (item.idMoneda / item.importeGeneral) y Descuento
// además se autocalcula (subtotal - costo final). El único campo editable
// de esta sección es Costo final.
class EditLeadFinancieraSection extends StatelessWidget {
  final TextEditingController cantidadCtrl;
  final TextEditingController precioBaseCtrl;
  final TextEditingController costoFinalCtrl;
  final List<MonedaItem> monedas;
  final MonedaItem? monedaItem;
  final bool isLoading;
  final double subtotal;
  final double descuento;
  final double costoFinal;

  const EditLeadFinancieraSection({
    super.key,
    required this.cantidadCtrl,
    required this.precioBaseCtrl,
    required this.costoFinalCtrl,
    required this.monedas,
    required this.monedaItem,
    required this.isLoading,
    required this.subtotal,
    required this.descuento,
    required this.costoFinal,
  });

  String get _simbolo => monedaItem?.simbolo ?? '';

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
            data: monedas,
            label: 'Moneda (*)',
            initialValue: monedaItem?.id,
            enabled: false,
            dense: true,
            prefixIcon: Icon(
              AppIcons.moneda,
              color: colorScheme.primary,
              size: AppSizing.iconActionSm,
            ),
          ),
          derecho: CustomTextField(
            label: 'Cantidad (*)',
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
            enabled: false,
            prefixText: '$_simbolo ',
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Descuento',
            controller: TextEditingController(
              text: NumberFormatUtils.formatMoneda(_simbolo, descuento),
            ),
            enabled: false,
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Costo final',
          controller: costoFinalCtrl,
          enabled: !isLoading,
          prefixText: '$_simbolo ',
          dense: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
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
