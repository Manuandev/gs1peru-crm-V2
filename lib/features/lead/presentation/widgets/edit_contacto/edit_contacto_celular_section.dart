// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_celular_section.dart
//
// Lista dinámica de celulares — una fila por número: [prefijo país] [número]
// [x eliminar] en una sola línea, y debajo Principal (radio, solo uno activo
// a la vez) / Favorito (checkbox amarillo) / Activo (checkbox). Sin límite de
// cantidad — pedido explícito del usuario. Prefijo usa el catálogo real
// (PaisItem) con combo de búsqueda — ya no el modal de country_picker
// (2026-07-23), mismo patrón que SolicitudCampoCelularBusqueda.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'contacto_form_rows.dart';

class EditContactoCelularSection extends StatelessWidget {
  final List<NumeroFormRow> numeros;
  final bool isLoading;
  final List<PaisItem> paises;
  final VoidCallback onAgregar;
  final ValueChanged<NumeroFormRow> onEliminar;
  final ValueChanged<NumeroFormRow> onTogglePrincipal;
  final void Function(NumeroFormRow row, bool value) onToggleFavorito;
  final void Function(NumeroFormRow row, bool value) onToggleActivo;
  final void Function(NumeroFormRow row, PaisItem pais) onCambioPais;
  final void Function(NumeroFormRow row) onCambioNumero;

  const EditContactoCelularSection({
    super.key,
    required this.numeros,
    required this.isLoading,
    required this.paises,
    required this.onAgregar,
    required this.onEliminar,
    required this.onTogglePrincipal,
    required this.onToggleFavorito,
    required this.onToggleActivo,
    required this.onCambioPais,
    required this.onCambioNumero,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionTitle('Celular (${numeros.length})'),
        const SizedBox(height: AppSpacing.md),
        for (final row in numeros) ...[
          _CelularRow(
            key: ValueKey(row.localId),
            row: row,
            isLoading: isLoading,
            paises: paises,
            onEliminar: () => onEliminar(row),
            onTogglePrincipal: () => onTogglePrincipal(row),
            onToggleFavorito: (v) => onToggleFavorito(row, v),
            onToggleActivo: (v) => onToggleActivo(row, v),
            onCambioPais: (p) => onCambioPais(row, p),
            onCambioNumero: () => onCambioNumero(row),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        CustomOutlinedButton(
          text: 'Agregar celular',
          icon: AppIcons.add,
          isEnabled: !isLoading,
          onPressed: onAgregar,
        ),
      ],
    );
  }
}

class _CelularRow extends StatelessWidget {
  final NumeroFormRow row;
  final bool isLoading;
  final List<PaisItem> paises;
  final VoidCallback onEliminar;
  final VoidCallback onTogglePrincipal;
  final ValueChanged<bool> onToggleFavorito;
  final ValueChanged<bool> onToggleActivo;
  final ValueChanged<PaisItem> onCambioPais;
  final VoidCallback onCambioNumero;

  const _CelularRow({
    super.key,
    required this.row,
    required this.isLoading,
    required this.paises,
    required this.onEliminar,
    required this.onTogglePrincipal,
    required this.onToggleFavorito,
    required this.onToggleActivo,
    required this.onCambioPais,
    required this.onCambioNumero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final data = paises
        .map(
          (p) =>
              '${p.codigoTelefono}${AppConstants.sepCampos}'
              '${p.nombre} (+${p.codigoTelefono})',
        )
        .toList();

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
                flex: 2,
                child: CustomComboSearchField(
                  data: data,
                  label: 'Prefijo',
                  enabled: !isLoading,
                  initialValue: row.pais?.codigoTelefono,
                  onChanged: (item) {
                    if (item == null) return;
                    final pais = paises
                        .where((p) => p.codigoTelefono == item.id)
                        .firstOrNull;
                    if (pais != null) onCambioPais(pais);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 3,
                child: CustomTextField(
                  label: 'Número',
                  controller: row.numeroCtrl,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  dense: true,
                  onChanged: (_) => onCambioNumero(),
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
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: row.esPrincipal ? true : null,
                onChanged: isLoading ? null : (_) => onTogglePrincipal(),
              ),
              const Text('Principal', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Checkbox(
                value: row.esFavorito,
                activeColor: AppColors.favorito,
                onChanged: isLoading
                    ? null
                    : (v) => onToggleFavorito(v ?? false),
              ),
              const Text('Favorito', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
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
