// lib/features/lead/presentation/widgets/edit_contacto/edit_contacto_datos_section.dart
//
// Sección "Datos de contacto" — identidad, documento, nacionalidad y
// ubicación (país/departamento/provincia/distrito). Prefijo (saludo) usa el
// catálogo real (PrefijoContactoItem, parte [20] del SP lstListas, agregada
// 2026-07-23) — antes era una lista fija local. Tipo de documento llega ya
// filtrado desde el Portrait (sin "Sin documento"). País usa combo con
// búsqueda, igual que Ubigeo. Número de documento dispara autocompletado
// (mismo patrón que solicitudes — ver EditContactoPortrait._buscarDocumento).

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class EditContactoDatosSection extends StatelessWidget {
  final bool isLoading;
  final List<PrefijoContactoItem> prefijosContacto;
  final String? saludoInicial;
  final ValueChanged<String?> onSaludoChanged;
  final TextEditingController linkedinCtrl;
  final List<TipoDocumentoItem> tiposDocumento;
  final TipoDocumentoItem? tipoDocumento;
  final ValueChanged<TipoDocumentoItem?> onTipoDocumentoChanged;
  final TextEditingController numeroDocumentoCtrl;
  final FocusNode numeroDocumentoFocus;
  final VoidCallback? onBuscarDocumento;
  final ValoresCRMItem valoresDefecto;
  final List<NacionalidadItem> nacionalidades;
  final NacionalidadItem? nacionalidad;
  final ValueChanged<NacionalidadItem?> onNacionalidadChanged;
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoPaternoCtrl;
  final TextEditingController apellidoMaternoCtrl;
  final List<PaisItem> paises;
  final PaisItem? pais;
  final ValueChanged<PaisItem?> onPaisChanged;
  final List<UbigeoItem> departamentos;
  final List<UbigeoItem> provincias;
  final List<UbigeoItem> distritos;
  final String? departamentoInicialId;
  final String? provinciaInicialId;
  final String? distritoInicialId;
  final ValueChanged<UbigeoItem?> onDepartamentoChanged;
  final ValueChanged<UbigeoItem?> onProvinciaChanged;
  final ValueChanged<UbigeoItem?> onDistritoChanged;
  final TextEditingController direccionCtrl;

  const EditContactoDatosSection({
    super.key,
    required this.isLoading,
    required this.prefijosContacto,
    required this.saludoInicial,
    required this.onSaludoChanged,
    required this.linkedinCtrl,
    required this.tiposDocumento,
    required this.tipoDocumento,
    required this.onTipoDocumentoChanged,
    required this.numeroDocumentoCtrl,
    required this.numeroDocumentoFocus,
    this.onBuscarDocumento,
    required this.valoresDefecto,
    required this.nacionalidades,
    required this.nacionalidad,
    required this.onNacionalidadChanged,
    required this.nombreCtrl,
    required this.apellidoPaternoCtrl,
    required this.apellidoMaternoCtrl,
    required this.paises,
    required this.pais,
    required this.onPaisChanged,
    required this.departamentos,
    required this.provincias,
    required this.distritos,
    required this.departamentoInicialId,
    required this.provinciaInicialId,
    required this.distritoInicialId,
    required this.onDepartamentoChanged,
    required this.onProvinciaChanged,
    required this.onDistritoChanged,
    required this.direccionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Datos de contacto'),
        const SizedBox(height: AppSpacing.md),

        FormFieldRow(
          izquierdo: CustomComboField<PrefijoContactoItem>(
            data: prefijosContacto,
            label: 'Prefijo',
            enabled: !isLoading,
            initialValue: saludoInicial,
            onChanged: (item) => onSaludoChanged(item?.valor),
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'LinkedIn',
            hint: 'linkedin.com/in/...',
            controller: linkedinCtrl,
            enabled: !isLoading,
            prefixIcon: resolveIcon(
              AppIcons.linkedin,
              AppSizing.iconActionSm,
              AppColors.textSecondary,
            ),
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomComboField<TipoDocumentoItem>(
            data: tiposDocumento,
            labelIndex: 2,
            label: 'Tipo de documento',
            enabled: !isLoading,
            initialValue: tipoDocumento?.id,
            onChanged: onTipoDocumentoChanged,
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Número de documento',
            controller: numeroDocumentoCtrl,
            focusNode: numeroDocumentoFocus,
            enabled: !isLoading,
            isUpperCase: true,
            keyboardType: DocumentoValidationUtils.keyboardType(
              tipoDocumento?.id ?? '',
              valoresDefecto,
            ),
            maxLength: DocumentoValidationUtils.maxLength(
              tipoDocumento?.id ?? '',
              tiposDocumento,
              valoresDefecto,
            ),
            inputFormatters: DocumentoValidationUtils.inputFormatters(
              tipoDocumento?.id ?? '',
              valoresDefecto,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onBuscarDocumento?.call(),
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        _ComboBusquedaCatalogo<NacionalidadItem>(
          label: 'Nacionalidad',
          items: nacionalidades,
          idDe: (n) => n.id,
          nombreDe: (n) => n.nombre,
          enabled: !isLoading,
          initialValue: nacionalidad?.id,
          onChanged: onNacionalidadChanged,
        ),
        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Nombres',
          controller: nombreCtrl,
          enabled: !isLoading,
          textCapitalization: TextCapitalization.words,
          isUpperCase: true,
          prefixIcon: const Icon(AppIcons.user),
          dense: true,
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: CustomTextField(
            label: 'Apellido paterno',
            controller: apellidoPaternoCtrl,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            isUpperCase: true,
            dense: true,
          ),
          derecho: CustomTextField(
            label: 'Apellido materno',
            controller: apellidoMaternoCtrl,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            isUpperCase: true,
            dense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        _ComboBusquedaCatalogo<PaisItem>(
          label: 'País',
          items: paises,
          idDe: (p) => p.id,
          nombreDe: (p) => p.nombre,
          enabled: !isLoading,
          initialValue: pais?.id,
          onChanged: onPaisChanged,
        ),
        const SizedBox(height: AppSpacing.sm),

        FormFieldRow(
          izquierdo: _ComboBusquedaUbigeo(
            label: 'Departamento',
            items: departamentos,
            nivel: (u) => u.dpto,
            enabled: !isLoading,
            initialValue: departamentoInicialId,
            onChanged: onDepartamentoChanged,
          ),
          derecho: _ComboBusquedaUbigeo(
            key: ValueKey('ubigeo-prov-$departamentoInicialId'),
            label: 'Provincia',
            items: provincias,
            nivel: (u) => u.prov,
            enabled: !isLoading,
            initialValue: provinciaInicialId,
            onChanged: onProvinciaChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ComboBusquedaUbigeo(
          key: ValueKey('ubigeo-dis-$departamentoInicialId-$provinciaInicialId'),
          label: 'Distrito',
          items: distritos,
          nivel: (u) => u.dis,
          enabled: !isLoading,
          initialValue: distritoInicialId,
          onChanged: onDistritoChanged,
        ),
        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Dirección',
          hint: 'Av. / Jr. / Calle, número',
          controller: direccionCtrl,
          enabled: !isLoading,
          isUpperCase: true,
          dense: true,
        ),
      ],
    );
  }
}

// Combo de búsqueda para un nivel de Ubigeo — mismo patrón que
// solicitudes/_ComboBusquedaUbigeo (ver solicitud_facturacion_view.dart).
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

// Combo de búsqueda genérico para cualquier catálogo (id, nombre) — usado
// para País (Datos de contacto). Mismo envoltorio de CustomComboSearchField
// que _ComboBusquedaUbigeo, pero para catálogos planos id/nombre.
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
