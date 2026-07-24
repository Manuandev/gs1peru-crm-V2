// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_empresa_section.dart
//
// Lista de empresas asociadas al contacto — cada card se puede expandir/
// contraer (header con nombre + subtítulo "cargo · área", botón +/- y "x"
// para eliminar). Área/Cargo/País/Ubigeo usan catálogo real (SYSTABEXTER02
// CODTABLA='AOF' / DBO.SYSMCARGO01 / PaisItem / UbigeoItem) desde
// 2026-07-23 — ver lead/CLAUDE.md. RUC dispara autocompletado (Clientes/
// BuscarDocumento) al perder foco, mismo patrón que Número de documento en
// Datos de contacto. Orden de campos (pedido de negocio): País+RUC / Razón
// social / Área+Cargo / Departamento+Provincia / Distrito / Dirección.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'contacto_form_rows.dart';

class EditContactoEmpresaSection extends StatelessWidget {
  final List<EmpresaFormRow> empresas;
  final bool isLoading;
  final List<PaisItem> paises;
  final List<AreaItem> areas;
  final List<CargoItem> cargos;
  final List<UbigeoItem> ubigeo;
  final VoidCallback onAgregar;
  final ValueChanged<EmpresaFormRow> onEliminar;
  final ValueChanged<EmpresaFormRow> onToggleExpandido;
  final ValueChanged<EmpresaFormRow> onCambioCampo;
  final void Function(EmpresaFormRow row, PaisItem? pais) onPaisChanged;
  final void Function(EmpresaFormRow row, AreaItem? area) onAreaChanged;
  final void Function(EmpresaFormRow row, CargoItem? cargo) onCargoChanged;
  final void Function(EmpresaFormRow row, UbigeoItem? item) onDepartamentoChanged;
  final void Function(EmpresaFormRow row, UbigeoItem? item) onProvinciaChanged;
  final void Function(EmpresaFormRow row, UbigeoItem? item) onDistritoChanged;
  final void Function(EmpresaFormRow row)? onBuscarRuc;

  const EditContactoEmpresaSection({
    super.key,
    required this.empresas,
    required this.isLoading,
    required this.paises,
    required this.areas,
    required this.cargos,
    required this.ubigeo,
    required this.onAgregar,
    required this.onEliminar,
    required this.onToggleExpandido,
    required this.onCambioCampo,
    required this.onPaisChanged,
    required this.onAreaChanged,
    required this.onCargoChanged,
    required this.onDepartamentoChanged,
    required this.onProvinciaChanged,
    required this.onDistritoChanged,
    this.onBuscarRuc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionTitle('Empresa (${empresas.length})'),
        const SizedBox(height: AppSpacing.md),
        for (final row in empresas) ...[
          _EmpresaCard(
            key: ValueKey(row.localId),
            row: row,
            isLoading: isLoading,
            paises: paises,
            areas: areas,
            cargos: cargos,
            ubigeo: ubigeo,
            onEliminar: () => onEliminar(row),
            onToggleExpandido: () => onToggleExpandido(row),
            onCambioCampo: () => onCambioCampo(row),
            onPaisChanged: (item) => onPaisChanged(row, item),
            onAreaChanged: (item) => onAreaChanged(row, item),
            onCargoChanged: (item) => onCargoChanged(row, item),
            onDepartamentoChanged: (item) => onDepartamentoChanged(row, item),
            onProvinciaChanged: (item) => onProvinciaChanged(row, item),
            onDistritoChanged: (item) => onDistritoChanged(row, item),
            onBuscarRuc: onBuscarRuc == null ? null : () => onBuscarRuc!(row),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        InkWell(
          onTap: isLoading ? null : onAgregar,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.add, size: AppSizing.iconActionSm, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Agregar empresa',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmpresaCard extends StatelessWidget {
  final EmpresaFormRow row;
  final bool isLoading;
  final List<PaisItem> paises;
  final List<AreaItem> areas;
  final List<CargoItem> cargos;
  final List<UbigeoItem> ubigeo;
  final VoidCallback onEliminar;
  final VoidCallback onToggleExpandido;
  final VoidCallback onCambioCampo;
  final ValueChanged<PaisItem?> onPaisChanged;
  final ValueChanged<AreaItem?> onAreaChanged;
  final ValueChanged<CargoItem?> onCargoChanged;
  final ValueChanged<UbigeoItem?> onDepartamentoChanged;
  final ValueChanged<UbigeoItem?> onProvinciaChanged;
  final ValueChanged<UbigeoItem?> onDistritoChanged;
  final VoidCallback? onBuscarRuc;

  const _EmpresaCard({
    super.key,
    required this.row,
    required this.isLoading,
    required this.paises,
    required this.areas,
    required this.cargos,
    required this.ubigeo,
    required this.onEliminar,
    required this.onToggleExpandido,
    required this.onCambioCampo,
    required this.onPaisChanged,
    required this.onAreaChanged,
    required this.onCargoChanged,
    required this.onDepartamentoChanged,
    required this.onProvinciaChanged,
    required this.onDistritoChanged,
    this.onBuscarRuc,
  });

  @override
  Widget build(BuildContext context) {
    final departamentos = ubigeo
        .where((u) => u.prov == '00' && u.dis == '00')
        .toList();
    final provincias = ubigeo
        .where(
          (u) =>
              u.dpto == (row.departamento?.dpto ?? '') &&
              u.prov != '00' &&
              u.dis == '00',
        )
        .toList();
    final distritos = ubigeo
        .where(
          (u) =>
              u.dpto == (row.departamento?.dpto ?? '') &&
              u.prov == (row.provincia?.prov ?? '') &&
              u.dis != '00',
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightVariant,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.nombreCtrl.text.isEmpty
                          ? 'Nueva empresa'
                          : row.nombreCtrl.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    if (row.subtitulo.isNotEmpty)
                      Text(
                        row.subtitulo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isLoading ? null : onEliminar,
                icon: const Icon(AppIcons.close, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: AppSizing.iconActionSm,
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onToggleExpandido,
                borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  child: Icon(
                    row.expandido ? AppIcons.remove : AppIcons.add,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (row.expandido) ...[
            const SizedBox(height: AppSpacing.sm),
            // País + RUC
            FormFieldRow(
              izquierdo: _ComboBusquedaCatalogo<PaisItem>(
                label: 'País',
                items: paises,
                idDe: (p) => p.id,
                nombreDe: (p) => p.nombre,
                enabled: !isLoading,
                initialValue: row.pais?.id,
                onChanged: onPaisChanged,
              ),
              derecho: CustomTextField(
                label: 'RUC',
                controller: row.rucCtrl,
                focusNode: row.rucFocus,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                maxLength: 11,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onBuscarRuc?.call(),
                dense: true,
                onChanged: (_) => onCambioCampo(),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Razón social
            CustomTextField(
              label: 'Razón social',
              controller: row.razonSocialCtrl,
              enabled: !isLoading,
              isUpperCase: true,
              dense: true,
              onChanged: (_) => onCambioCampo(),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Área + Cargo
            FormFieldRow(
              izquierdo: CustomComboSearchField(
                data: areas
                    .map((a) => '${a.id}${AppConstants.sepCampos}${a.nombre}')
                    .toList(),
                label: 'Área',
                enabled: !isLoading,
                initialValue: row.area?.id,
                onChanged: (item) {
                  if (item == null) {
                    onAreaChanged(null);
                    return;
                  }
                  onAreaChanged(areas.where((a) => a.id == item.id).firstOrNull);
                },
              ),
              derecho: CustomComboSearchField(
                data: cargos
                    .map((c) => '${c.id}${AppConstants.sepCampos}${c.nombre}')
                    .toList(),
                label: 'Cargo',
                enabled: !isLoading,
                initialValue: row.cargo?.id,
                onChanged: (item) {
                  if (item == null) {
                    onCargoChanged(null);
                    return;
                  }
                  onCargoChanged(cargos.where((c) => c.id == item.id).firstOrNull);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Departamento + Provincia
            FormFieldRow(
              izquierdo: _ComboBusquedaUbigeo(
                label: 'Departamento',
                items: departamentos,
                nivel: (u) => u.dpto,
                enabled: !isLoading,
                initialValue: row.departamento?.dpto,
                onChanged: onDepartamentoChanged,
              ),
              derecho: _ComboBusquedaUbigeo(
                key: ValueKey('emp-ubigeo-prov-${row.localId}-${row.departamento?.dpto}'),
                label: 'Provincia',
                items: provincias,
                nivel: (u) => u.prov,
                enabled: !isLoading,
                initialValue: row.provincia?.prov,
                onChanged: onProvinciaChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Distrito
            _ComboBusquedaUbigeo(
              key: ValueKey(
                'emp-ubigeo-dis-${row.localId}-${row.departamento?.dpto}-${row.provincia?.prov}',
              ),
              label: 'Distrito',
              items: distritos,
              nivel: (u) => u.dis,
              enabled: !isLoading,
              initialValue: row.distrito?.dis,
              onChanged: onDistritoChanged,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Dirección
            CustomTextField(
              label: 'Dirección',
              controller: row.direccionCtrl,
              enabled: !isLoading,
              isUpperCase: true,
              dense: true,
              onChanged: (_) => onCambioCampo(),
            ),
          ],
        ],
      ),
    );
  }
}

// Combo de búsqueda para un nivel de Ubigeo — mismo patrón que
// edit_contacto_datos_section.dart._ComboBusquedaUbigeo (duplicado a
// propósito, cada archivo se mantiene sin depender del otro).
class _ComboBusquedaUbigeo extends StatelessWidget {
  final String label;
  final List<UbigeoItem> items;
  final String Function(UbigeoItem) nivel;
  final bool enabled;
  final String? initialValue;
  final ValueChanged<UbigeoItem?>? onChanged;

  const _ComboBusquedaUbigeo({
    super.key,
    required this.label,
    required this.items,
    required this.nivel,
    required this.enabled,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = items
        .map((u) => '${nivel(u)}${AppConstants.sepCampos}${u.nombre}')
        .toList();

    return CustomComboSearchField(
      data: data,
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      onChanged: (item) {
        if (item == null) {
          onChanged?.call(null);
          return;
        }
        final seleccionado = items.where((u) => nivel(u) == item.id).firstOrNull;
        onChanged?.call(seleccionado);
      },
    );
  }
}

// Combo de búsqueda genérico id/nombre — mismo patrón que
// edit_contacto_datos_section.dart._ComboBusquedaCatalogo.
class _ComboBusquedaCatalogo<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final String Function(T) idDe;
  final String Function(T) nombreDe;
  final bool enabled;
  final String? initialValue;
  final ValueChanged<T?>? onChanged;

  const _ComboBusquedaCatalogo({
    required this.label,
    required this.items,
    required this.idDe,
    required this.nombreDe,
    required this.enabled,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = items
        .map((e) => '${idDe(e)}${AppConstants.sepCampos}${nombreDe(e)}')
        .toList();

    return CustomComboSearchField(
      data: data,
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      onChanged: (item) {
        if (item == null) {
          onChanged?.call(null);
          return;
        }
        final seleccionado = items.where((e) => idDe(e) == item.id).firstOrNull;
        onChanged?.call(seleccionado);
      },
    );
  }
}
