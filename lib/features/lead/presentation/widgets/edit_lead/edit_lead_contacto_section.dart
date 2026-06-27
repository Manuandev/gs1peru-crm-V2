// lib/features/lead/presentation/widgets/edit_lead/edit_lead_contacto_section.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadContactoSection extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoPCtrl;
  final TextEditingController apellidoMCtrl;
  final TextEditingController empresaCtrl;
  final TextEditingController correoCtrl;
  final String telefonoPrefijo;
  final String telefonoNumero;
  final bool isLoading;
  final bool mostrarAgregarNumero;
  final VoidCallback onToggleTelefono;
  final void Function(String prefijo, String numero) onAgregarNumero;

  const EditLeadContactoSection({
    super.key,
    required this.nombreCtrl,
    required this.apellidoPCtrl,
    required this.apellidoMCtrl,
    required this.empresaCtrl,
    required this.correoCtrl,
    required this.telefonoPrefijo,
    required this.telefonoNumero,
    required this.isLoading,
    required this.mostrarAgregarNumero,
    required this.onToggleTelefono,
    required this.onAgregarNumero,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información del contacto'),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Nombres',
          controller: nombreCtrl,
          enabled: !isLoading,
          prefixIcon: const Icon(AppIcons.user),
          textCapitalization: TextCapitalization.words,
          dense: true,
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Apellido Paterno',
            controller: apellidoPCtrl,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Apellido Materno',
            controller: apellidoMCtrl,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Empresa',
            controller: empresaCtrl,
            enabled: false,
            prefixIcon: const Icon(AppIcons.business),
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Cargo',
            controller: TextEditingController(),
            enabled: false,
            prefixIcon: const Icon(AppIcons.documento),
            hint: 'Próximamente',
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildTelefonoCampo()),
            const SizedBox(width: AppSpacing.xs),
            _buildToggleBtn(context),
          ],
        ),

        if (mostrarAgregarNumero) ...[
          const SizedBox(height: AppSpacing.xs),
          AgregarNumeroPanel(
            onCancelar: onToggleTelefono,
            onAgregar: (prefijo, numero) => onAgregarNumero(prefijo, numero),
          ),
        ],

        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Correo',
          controller: correoCtrl,
          enabled: false,
          prefixIcon: const Icon(AppIcons.email),
          dense: true,
        ),
      ],
    );
  }

  Widget _buildTelefonoCampo() {
    return CustomTextField(
      label: 'Teléfono',
      controller: TextEditingController(
        text: '$telefonoPrefijo $telefonoNumero',
      ),
      enabled: false,
      prefixIcon: const Icon(AppIcons.phone),
      dense: true,
    );
  }

  Widget _buildToggleBtn(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: isLoading ? null : onToggleTelefono,
      borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: mostrarAgregarNumero ? colorScheme.error : colorScheme.primary,
            width: AppSizing.hairline,
          ),
        ),
        child: Icon(
          mostrarAgregarNumero ? AppIcons.close : AppIcons.add,
          size: AppSizing.iconActionSm,
          color: mostrarAgregarNumero ? colorScheme.error : colorScheme.primary,
        ),
      ),
    );
  }
}
