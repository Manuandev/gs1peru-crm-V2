// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_correo_section.dart
//
// Lista dinámica de correos — una fila por correo: [input correo] [x
// eliminar] en una sola línea, con un checkbox "Activo" debajo. Sin límite
// de cantidad — pedido explícito del usuario.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'contacto_form_rows.dart';

class EditContactoCorreoSection extends StatelessWidget {
  final List<CorreoFormRow> correos;
  final bool isLoading;
  final VoidCallback onAgregar;
  final ValueChanged<CorreoFormRow> onEliminar;
  final void Function(CorreoFormRow row, bool value) onToggleActivo;
  final void Function(CorreoFormRow row) onCambioCorreo;

  const EditContactoCorreoSection({
    super.key,
    required this.correos,
    required this.isLoading,
    required this.onAgregar,
    required this.onEliminar,
    required this.onToggleActivo,
    required this.onCambioCorreo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionTitle('Correo (${correos.length})'),
        const SizedBox(height: AppSpacing.md),
        for (final row in correos) ...[
          _CorreoRow(
            key: ValueKey(row.localId),
            row: row,
            isLoading: isLoading,
            onEliminar: () => onEliminar(row),
            onToggleActivo: (v) => onToggleActivo(row, v),
            onCambioCorreo: () => onCambioCorreo(row),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        CustomOutlinedButton(
          text: 'Agregar correo',
          icon: AppIcons.add,
          isEnabled: !isLoading,
          onPressed: onAgregar,
        ),
      ],
    );
  }
}

class _CorreoRow extends StatelessWidget {
  final CorreoFormRow row;
  final bool isLoading;
  final VoidCallback onEliminar;
  final ValueChanged<bool> onToggleActivo;
  final VoidCallback onCambioCorreo;

  const _CorreoRow({
    super.key,
    required this.row,
    required this.isLoading,
    required this.onEliminar,
    required this.onToggleActivo,
    required this.onCambioCorreo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Correo',
                  controller: row.correoCtrl,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  isUpperCase: true,
                  dense: true,
                  onChanged: (_) => onCambioCorreo(),
                  validator: (v) => v.emailValidator,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                onPressed: isLoading ? null : onEliminar,
                icon: const Icon(AppIcons.close, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: AppSizing.iconActionSm,
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: row.activo,
                onChanged: isLoading ? null : (v) => onToggleActivo(v ?? false),
              ),
              const Text('Activo', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
